//
//  CAUPNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 12-12-6.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "CAUPNewsModel.h"
#import "UIApplication+Toast.h"
#import "FakeNews.h"
#import "DataOperator.h"
#import "NSString+URLRequest.h"
#import "NSString+HTML.h"

@implementation CAUPNewsModel

-(id)init
{
    if(self = [super init])
    {
        webview = [[UIWebView alloc] init];
        webview.delegate = self;
        
        isgetting = NO;

        urlToRetireve = [@[] mutableCopy];
        
        timeToWait = 0;
        iamwaiting = NO;
    }
    return self;
}


-(void)save
{
    for(int i = 0; i <[self totalNewsCount]; i++)
    {
        if([self shouldSaveThisNewsWithThisDate:[self timeForNewsIndex:i]])
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
}


- (void)startDownloadList
{
    dict = [@[] mutableCopy];
    
    [webview loadRequest:[@"http://old.tongji-caup.org/student/News_nmore.asp" convertToURLRequest]];
    
}

#pragma mark web view delegate

- (void)parseList:(NSString*)source
{
    while(1)
    {
        @try {
            NSRange range = [source rangeOfString:@"<td align=\"left\" class=\"TLE\" width=\"736\" valign=\"top\"><span class=\"Hdate\">["];
            if(range.location == NSNotFound)
                break;
            source = [source substringFromIndex:range.location + range.length];
            NSString* date = [source substringToIndex:5];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            if([date hasPrefix:@"0"] && ![date hasPrefix:@"09"])
            {
                date = [@"2013" stringByAppendingString:date];
            }
            else
            {
                date = [@"2012" stringByAppendingString:date];
            }
            [df setDateFormat:@"yyyyMM-dd"];
            NSDate *myDate = [df dateFromString: date];
            
            NSLog(@"news time: %@",myDate);
            range = [source rangeOfString:@"<a href=\"news_detail.asp?id="];
            source = [source substringFromIndex:range.location + range.length];
            NSString *newsURL = [source substringToIndex:4];
            
            range = [source rangeOfString:@"\">"];
            source = [source substringFromIndex:range.location + range.length];
            range = [source rangeOfString:@"</a></td>"];
            NSString* title = [source substringToIndex:range.location];
            
            NSDictionary *item = @{@"url":newsURL, @"title":title, @"date": myDate};
            [dict addObject:item];
        }
        @catch (NSException *exception) {
            NSLog(@"CAUD parse list fail due to %@",exception);
        }
        @finally {
            
        }
        
    }

}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] hideNetworkIndicator];
    NSString *currentURL = webView.request.URL.absoluteString;
    
    NSLog(@"CAUD finish loading: %@",currentURL);
    
    if([currentURL isEqualToString:@"http://old.tongji-caup.org/student/News_nmore.asp"])
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
    if(iamwaiting)
        return;
    while(timeToWait >= 1)
    {
        iamwaiting = YES;
        sleep(1);
        timeToWait --;
    }
    iamwaiting = NO;
    NSLog(@"URL TO GO %@",urlToRetireve);
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
    
    @try {
        NSRange start = [tempContent rangeOfString:@"发布时间："];
        
        tempContent = [tempContent substringFromIndex:start.location + start.length];
        
        
        NSString* timeYear = [tempContent substringToIndex:4];
        
        NSString* originalDate = [news.date description];
        
        originalDate = [originalDate substringFromIndex:4];
        
        originalDate = [timeYear stringByAppendingString:originalDate];
        originalDate = [originalDate substringToIndex:10];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *myDate = [df dateFromString: originalDate];
        
        news.date = myDate;
        
        start = [tempContent rangeOfString:@"class=\"TLE\">"];
        
        tempContent = [tempContent substringFromIndex:start.location + start.length];
        
        //NSRange end = [tempContent rangeOfString:@"<!--内容-->"];
        
        //tempContent = [tempContent substringToIndex:end.location];
        
        if(news.content)
        {
            if(news.content.length < tempContent.length)
                news.content = tempContent;
        }
        else
            news.content = tempContent;
        
        
        NSString *briefContent = [news.content  stringByConvertingHTMLToPlainText];
        
        briefContent =  [briefContent stringByReplacingOccurrencesOfString: @"\r" withString:@""];
        briefContent =  [briefContent stringByReplacingOccurrencesOfString: @"\n" withString:@""];
        //briefContent =  [briefContent stringByReplacingOccurrencesOfString: news.title withString:@""];
        briefContent =  [briefContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        news.briefcontent = briefContent;
        
        //NSLog(@"URL:%@ Content:%@",url,tempBriefContent);
        [[MyDataStorage instance] saveContext];

    }
    @catch (NSException *exception) {
        NSLog(@"caught in caud with news urld: %@, %@", news.url, exception);
    }
    @finally {
        timeToWait = 5;
        [self retreivingTherad];
        //[self performSelector:@selector(retreivingTherad) withObject:nil afterDelay:7];
        //[self retreivingTherad];
    }
    
}


-(BOOL)retreiveDetailForUrlLocal:(NSString*)url
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    
    url = [@"http://old.tongji-caup.org/student/news_detail.asp?id=" stringByAppendingString:url];
    
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
    return dict[index][@"date"];
}

@end
