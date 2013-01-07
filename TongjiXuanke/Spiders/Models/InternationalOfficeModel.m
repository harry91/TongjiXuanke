//
//  InternationalOfficeModel.m
//  TongjiXuanke
//
//  Created by Song on 12-12-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "InternationalOfficeModel.h"
#import "UIApplication+Toast.h"
#import "FakeNews.h"
#import "DataOperator.h"
#import "NSString+URLRequest.h"
#import "NSString+HTML.h"

@implementation InternationalOfficeModel
-(id)init
{
    if(self = [super init])
    {
        webview = [[UIWebView alloc] init];
        webview.delegate = self;
        
        isgetting = NO;
        
        urlToRetireve = [@[] mutableCopy];
    }
    return self;
}


-(void)save
{
    for(int i = 0; i <[self totalNewsCount]; i++)
    {
        FakeNews *news = [[FakeNews alloc] init];
        news.title = [self titleForNewsIndex:i];
        
        news.briefcontent = nil;
        
        news.content = nil;
        news.date = [self timeForNewsIndex:i];
        news.favorated = NO;
        news.haveread = NO;
        news.url = [self idForNewsIndex:i];
        [[DataOperator instance] distinctSave:news inCategory:[self catagoryForNews]];
    }
}


- (void)startDownloadList
{
    dict = [@[] mutableCopy];
    
    [webview loadRequest:[@"http://www.tongji-uni.com/newslist.aspx?intclass=1" convertToURLRequest]];
    
}

#pragma mark web view delegate

- (void)parseList:(NSString*)source
{
    while(1)
    {
        @try {
            NSRange range = [source rangeOfString:@"<tr align=\"left\" valign=\"middle\" style=\"color:#424242;background-color:#424242;\">"];
            if(range.location == NSNotFound)
                break;
            source = [source substringFromIndex:range.location + range.length];
            range = [source rangeOfString:@"<td><a href=\"newsshow.aspx?sn="];
            source = [source substringFromIndex:range.location + range.length];
            NSString *newsURL = [source substringToIndex:4];
            
            range = [source rangeOfString:@"\">"];
            source = [source substringFromIndex:range.location + range.length];
            range = [source rangeOfString:@"</a></td>"];
            NSString* title = [source substringToIndex:range.location];
            
            NSDictionary *item = @{@"url":newsURL, @"title":title};
            [dict addObject:item];
        }
        @catch (NSException *exception) {
            NSLog(@"IO parse list fail due to %@",exception);
        }
        @finally {
            
        }
        
    }
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] hideNetworkIndicator];
    NSString *currentURL = webView.request.URL.absoluteString;
    
    NSLog(@"IO finish loading: %@",currentURL);
    
    if([currentURL isEqualToString:@"http://www.tongji-uni.com/newslist.aspx?intclass=1"])
    {
        tempContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
        [self parseList:tempContent];
        [self save];
        [self.delegate finishedLoadingInCategory:self.categoryIndex];
        return;
    }
    
    else
    {
        NSString *url = [currentURL substringFromIndex:currentURL.length - 4];
        tempContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
        tempBriefContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText;"];
        [self finishRetreiving:url];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

#pragma mark detail getting
-(void)retreivingTherad
{
    if(urlToRetireve.count <= 0)
    {
        isgetting = NO;
        return;
    }
    isgetting = YES;
    curl = urlToRetireve[0];
    [urlToRetireve removeObjectAtIndex:0];
    [self retreiveDetailForUrlLocal:curl];
}

-(BOOL)retreiveDetailForUrl:(NSString*)url
{
    [urlToRetireve insertObject:url atIndex:0];
    if(!isgetting)
    {
        [self retreivingTherad];
    }
    return YES;///TODO bug.....
}

- (void)finishRetreiving:(NSString *)aUrl
{
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(url == %@)", aUrl]];
    
    // make sure the results are sorted as well
    
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!matching)
    {
        NSLog(@"Error: %@",[error description]);
    }
    News *news;
    if(matching.count > 0)
    {
        for(News *item in matching)
        {
            if([item.category.name isEqualToString:[self catagoryForNews]])
            {
                news = item;
                break;
            }
        }
    }
    
    NSString* backupstring = [tempContent copy];
    
    
    @try {
        
        
        NSRange start = [tempContent rangeOfString:@"lblTime\">"];
        
        tempContent = [tempContent substringFromIndex:start.location + start.length];
        
        NSRange end = [tempContent rangeOfString:@"</span>"];
        
        
        NSString* timeString = [tempContent substringToIndex:end.location];
        end = [timeString rangeOfString:@" "];
        timeString = [timeString substringToIndex:end.location];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        
        [df setDateFormat:@"yyyy-M-d"];
        NSDate *myDate = [df dateFromString: timeString];
        
        news.date = myDate;
        
        tempContent = [backupstring copy];
        
        start = [backupstring rangeOfString:@"<b><span id=\"lblTitle\">"];
        
        backupstring = [backupstring substringFromIndex:start.location];
        
        end = [backupstring rangeOfString:@"<p></p><div align=\"right\"><a href=\"default.aspx\">"];
        
        backupstring = [backupstring substringToIndex:end.location];
        
        backupstring =  [backupstring stringByReplacingOccurrencesOfString: @"#ffffff" withString:@"#777777"];
        
        
        if(news.content)
        {
            if(news.content.length < backupstring.length)
                news.content = backupstring;
        }
        else
            news.content = backupstring;
        
        
        start = [backupstring rangeOfString:@"<td class=\"wh\">"];
        
        backupstring = [backupstring substringFromIndex:start.location];
        
        NSString *briefContent = [backupstring  stringByConvertingHTMLToPlainText];
        
        briefContent =  [briefContent stringByReplacingOccurrencesOfString: @"\r" withString:@""];
        briefContent =  [briefContent stringByReplacingOccurrencesOfString: @"\n" withString:@""];
        //briefContent =  [briefContent stringByReplacingOccurrencesOfString: news.title withString:@""];
        briefContent =  [briefContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        news.briefcontent = briefContent;
        if(![self shouldSaveThisNewsWithThisDate:news.date])
        {
            news.title = @"snow";
            news.content = @"snow";
            news.briefcontent = @"snow";
        }
        [[MyDataStorage instance] saveContext];
        //NSLog(@"URL:%@ Content:%@",url,tempBriefContent);
    }
    @catch (NSException *exception) {
        NSLog(@"caught in od with news urld: %@, %@", news.url, exception);
    }
    @finally {
        [self performSelector:@selector(retreivingTherad) withObject:nil afterDelay:1];
        //[self retreivingTherad];
    }
    
}


-(BOOL)retreiveDetailForUrlLocal:(NSString*)url
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    
    url = [@"http://www.tongji-uni.com/newsshow.aspx?sn=" stringByAppendingString:url];
    
    [webview loadRequest:[url convertToURLRequest]];
    
    return YES;//TODO bug
}


-(void)retreiveDetails
{
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //[fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(category == %@)", [self catagoryForNews]]];
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    for(News* item in matching)
    {
        if(item.content == nil && [item.category.name isEqualToString:[self catagoryForNews]])
        {
            [self addURLtoRetirve:item.url];
        }
    }
}

-(void)addURLtoRetirve:(NSString*)url
{
    [urlToRetireve addObject:url];
    NSLog(@"URL TO GO %@",urlToRetireve);
    if(!isgetting)
    {
        [self retreivingTherad];
    }
}


#pragma mark News Feed Protocal
-(void)realStart
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    [self performSelectorInBackground:@selector(startDownloadList) withObject:nil];
}

-(int)totalNewsCount
{
    return dict.count;
}

-(NSString*)titleForNewsIndex:(int)index
{
    
    return dict[index][@"title"];
}

-(NSString*)contentForNewsIndex:(int)index
{
    return nil;
}

-(NSString*)idForNewsIndex:(int)index
{
    
    return dict[index][@"url"];
}

-(NSDate*)timeForNewsIndex:(int)index
{
    return nil;
}

-(NSString*)safariLink:(News*)aNews
{
    return [@"http://www.tongji-uni.com/newsshow.aspx?sn=" stringByAppendingString:aNews.url];
}

@end
