//
//  XuankeModel.m
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "XuankeModel.h"
#import "MyDataStorage.h"
#import "News.h"
#import "Category.h"
#import "ReachabilityChecker.h"
#import "SettingModal.h"
#import "DataOperator.h"
#import "SettingModal.h"
#import "NSString+EncryptAndDecrypt.h"
#import "UIApplication+Toast.h"

@implementation XuankeModel

-(id)init
{
    if(self = [super init])
    {
        _listView = [[UIWebView alloc] init];
        _detailView = [[UIWebView alloc] init];
        
        _listView.delegate = self;
        _detailView.delegate = self;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *username = [ud objectForKey:@"username"];
        NSString *pwd = [ud objectForKey:@"password"];
        pwd = [NSString stringByDecryptString:pwd];
        
        
        self.userName = username;
        self.password = pwd;
        
        dict = [@[] mutableCopy];
        
        isRetreivingThreadRunning = NO;
        detailGetting = NO;
        urlToRetireve = [@[] mutableCopy];
        
        loginModal = [[LogInModal alloc] init];
        loginModal.delegate = self;
        
        logined = NO;
    }
    return self;
}


-(void)login
{
    loginModal.userName = self.userName;
    loginModal.password = self.password;
    [loginModal start];
}

-(void)retrieveList
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    [_listView loadRequest:[@"http://xuanke.tongji.edu.cn/tj_login/index_main.jsp" convertToURLRequest]];
}

-(BOOL)parseResult:(NSString*)result
{
    dict = [[NSMutableArray alloc] init];
    if([result rangeOfString:@"showNotice"].length <= 0)
    {
        return NO;
    }
    NSMutableString *str = [result mutableCopy];
    NSRange range;
    while(1)
    {
        range = [str rangeOfString:@"onclick=\"showNotice('"];
        if(range.length <= 0)
            break;
        NSString *newsID = [str substringWithRange:NSMakeRange(range.location+range.length, 14)];
        str = [[str substringFromIndex:range.location+range.length] mutableCopy];
        range = [str rangeOfString:@"onclick=\"showNotice('"];
        NSRange r1,r2;
        r1 = [str rangeOfString:@"<font color=\"green\">\n"];
        r2 = [str rangeOfString:@"\n</font>\n"];
        
        NSString *newsTitle = [str substringWithRange:NSMakeRange(r1.length+r1.location, r2.location)];
        r1 = [newsTitle rangeOfString:@"."];
        r2 = [newsTitle rangeOfString:@"\n"];

        newsTitle = [newsTitle substringWithRange:NSMakeRange(r1.location + 1, r2.location - 2)];
        str = [[str substringFromIndex:r1.location] mutableCopy];
        
        NSDictionary *item = @{@"ID":newsID, @"Title":newsTitle};
        [dict addObject:item];
    }
    //NSLog(@"%@",dict);
    return YES;
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


#pragma mark UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *currentURL = webView.request.URL.absoluteString;
    
    NSLog(@"Finish loading: %@",currentURL);
    
    if(webView == _listView)
    {
        _content = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        NSLog(@"content: %@",_content);
        
        if([self parseResult:_content])
        {
            [self save];
            [self.delegate finishedLoadingInCategory:self.categoryIndex];
            [[UIApplication sharedApplication] hideNetworkIndicator];
            lastUpdateEnd = [NSDate date];
            tryTime = 0;
        }
        else
        {
            if(tryTime < 3)
            {
                [self login];
                logined = NO;
            }
            else
            {
                NSError *error = [[NSError alloc] initWithDomain:@"UnknownFormat" code:0 userInfo:nil];
                [self.delegate errorLoading:error inCategory:self.categoryIndex];
                [[UIApplication sharedApplication] hideNetworkIndicator];
            }
            tryTime++;
        }
    }
    else if(webView == _detailView)
    {
        tempContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
        tempBriefContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText;"];
        detailGetting = NO;
        [[UIApplication sharedApplication] hideNetworkIndicator];
        
        NSString *url = [currentURL substringWithRange:NSMakeRange(58, 14)];
        
        [self finishRetreiving:url];

    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",error);
    if(detailGetting)
    {
        detailGetting = NO;
        //[self retreivingTherad];
    }
    else [self.delegate errorLoading:error inCategory:self.categoryIndex];
}


#pragma mark NewsFeedProtocal delegate

-(void)realStart
{
    if(!logined)
        [self login];
    else
        [self retrieveList];
}


-(void)addURLtoRetirve:(NSString*)url
{
    [urlToRetireve addObject:url];
    if(!isRetreivingThreadRunning)
    {
        [self retreivingTherad];
    }
}


-(void)retreivingTherad
{
    NSLog(@"URL TO GO %@",urlToRetireve);
    if(urlToRetireve.count <= 0)
    {
        isRetreivingThreadRunning = NO;
        return;
    }
    isRetreivingThreadRunning = YES;
    NSString *url = urlToRetireve[0];
    [urlToRetireve removeObjectAtIndex:0];
    [self retreiveDetailForUrlLocal:url];

}

-(BOOL)retreiveDetailForUrl:(NSString*)url
{
    [urlToRetireve insertObject:url atIndex:0];
    if(!isRetreivingThreadRunning)
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
    
    tempContent = [tempContent stringByReplacingOccurrencesOfString:@"<link rel=\"stylesheet\" href=\"/tj_public/css/main.css\">" withString:@""];
    //newsString = [newsString stringByReplacingOccurrencesOfString:news.title withString:@""];
    tempContent = [tempContent stringByReplacingOccurrencesOfString:@"<input type=\"button\" class=\"INPUT_button\" value=\"关闭\" onclick=\"window.close()\">" withString:@""];
    news.content = tempContent;
    tempBriefContent =  [tempBriefContent stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    tempBriefContent =  [tempBriefContent stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    tempBriefContent =  [tempBriefContent stringByReplacingOccurrencesOfString: news.title withString:@""];
    tempBriefContent =  [tempBriefContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //tempBriefContent = [tempBriefContent substringFromIndex:news.title.length];
    news.briefcontent = tempBriefContent;
    //NSLog(@"URL:%@ Content:%@",url,tempBriefContent);
    [[MyDataStorage instance] saveContext];
    detailGetting = NO;
    [self retreivingTherad];
}

-(BOOL)retreiveDetailForUrlLocal:(NSString*)url
{
    BOOL result = NO;
    if([[ReachabilityChecker instance] hasInternetAccess])
    {
        if([[ReachabilityChecker instance] usingWIFI] || [[SettingModal instance] shouldDownloadAllContentWithoutWIFI])
        {
            result = YES;
        }
    }
    if(!result)
        return NO;
    
    if(detailGetting == YES)
    {
        return NO;
    }
    
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"url == %@", url]];
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    for(News* item in matching)
    {
        if(item.content == nil && [item.category.name isEqualToString:[self catagoryForNews]])
        {
            detailGetting = YES;
            
            NSString *urlToGo = @"http://xuanke.tongji.edu.cn/tj_public/jsp/tongzhi.jsp?id='URL'";
            urlToGo = [urlToGo stringByReplacingOccurrencesOfString:@"URL" withString:url];
            
            [[UIApplication sharedApplication] showNetworkIndicator];
            [_detailView loadRequest:[urlToGo convertToURLRequest]];
            
            return YES;//TODO bug
        }
    }

    return NO;
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

-(int)totalNewsCount
{
    return dict.count;
}

-(NSString*)titleForNewsIndex:(int)index
{
    return dict[index][@"Title"];
}

-(NSString*)contentForNewsIndex:(int)index
{
    return nil;
    ///TODO
}

-(NSString*)idForNewsIndex:(int)index
{
    return dict[index][@"ID"];
}


-(NSDate*)timeForNewsIndex:(int)index
{
    NSString *dateStr = dict[index][@"ID"];
    dateStr = [dateStr substringWithRange:NSMakeRange(0,8)];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd"];
    NSDate *myDate = [df dateFromString: dateStr];
    
    return myDate;
}


#pragma mark For login modal
-(void)LoginSuccess
{
    logined = YES;
    [self retrieveList];
}

-(void)LoginFailWithError:(NSError*)error
{
    
}


@end
