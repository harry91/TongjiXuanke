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

@implementation XuankeModel

-(id)init
{
    if(self = [super init])
    {
        _webView = [[UIWebView alloc] init];
        loginInState = 0;
        _webView.delegate = self;
        tryTime = 0;
        self.password = @"";
        dict = [@[] mutableCopy];
        self.userName = @"";
        detailGetting = NO;
    }
    return self;
}

-(void)setDelegate:(id<NewsLoaderProtocal>)delegate
{
    _delegate = delegate;
}

- (void)loadWebPageWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}


-(void)login
{
    [self loadWebPageWithString:@"http://tjis2.tongji.edu.cn:58080/amserver/UI/Login?goto=http%3A%2F%2Fxuanke.tongji.edu.cn%2Fpass.jsp"];
    loginInState = 0;
    detailGetting = NO;
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
    NSLog(@"%@",dict);
    return YES;
}


-(Category*)myCategory
{
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(name == %@)", [self catagoryForNews]]];
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!matching)
    {
        NSLog(@"Error: %@",[error description]);
    }
    if(matching.count > 0)
    {
        return [matching lastObject];
    }

    Category *category = [NSEntityDescription
              insertNewObjectForEntityForName:@"Category"
              inManagedObjectContext:context];
    category.name = [self catagoryForNews];
    [[MyDataStorage instance] saveContext];
    return category;
}


-(void)shallowSave
{
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    for(int i = 0; i <[self totalNewsCount]; i++)
    {
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:
         [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
        [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(url == %@)", [self idForNewsIndex:i]]];
        
        
        // make sure the results are sorted as well
         
        NSError *error;
        NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
        
        if(!matching)
        {
            NSLog(@"Error: %@",[error description]);
        }
        if(matching.count > 0)
        {
            BOOL found = NO;
            for(News *item in matching)
            {
                if([item.category.name isEqualToString:[self catagoryForNews]])
                {
                    found = YES;
                    break;
                }
            }
            if(found)
                continue;
        }
        
        News *news = [NSEntityDescription
                      insertNewObjectForEntityForName:@"News"
                      inManagedObjectContext:context];
        news.category = [self myCategory];
        news.title = [self titleForNewsIndex:i];
        news.briefcontent = nil;
        news.content = nil;
        news.date = [self timeForNewsIndex:i];
        news.favorated = NO;
        news.haveread = NO;
        news.url = [self idForNewsIndex:i];
    }
    [[MyDataStorage instance] saveContext];
}

#pragma mark UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *currentURL = _webView.request.URL.absoluteString;
    
    NSLog(@"Finish loading: %@",currentURL);
    NSLog(@"state: %d",loginInState);
    NSLog(@"Detail getting: %@",detailGetting?@"Y":@"N");
    
    if(!detailGetting)
    {
        if(loginInState == 1 && [currentURL isEqualToString:@"http://tjis2.tongji.edu.cn:58080/amserver/UI/Login"])
        {
            NSError *error = [[NSError alloc] initWithDomain:@"AccountOrPwdInvalid" code:0 userInfo:nil];
            [self.delegate errorLoading:error];
        }
        else if(loginInState == 0)
        {
            NSString *fillUserName = @"document.frm1.IDToken1.value='USERNAME';";
            NSString *fillPwd = @"document.frm2.IDToken2.value='PASSWORD';";
            fillUserName = [fillUserName stringByReplacingOccurrencesOfString:@"USERNAME" withString:self.userName];
            fillPwd = [fillPwd stringByReplacingOccurrencesOfString:@"PASSWORD" withString:self.password];
            
            [_webView stringByEvaluatingJavaScriptFromString:fillUserName];
            [_webView stringByEvaluatingJavaScriptFromString:fillPwd];
            [_webView stringByEvaluatingJavaScriptFromString:@"LoginSubmit('登录')"];
            loginInState ++;
        }
        else if(loginInState > 3 && loginInState < 100)
        {
            [self loadWebPageWithString:@"http://xuanke.tongji.edu.cn/tj_login/index_main.jsp"];
            loginInState = 100;
        }
        else if(loginInState == 100)
        {
            _content = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
            NSLog(@"content: %@",_content);
            loginInState = 101;
            
        }
        else if(loginInState == 101)
        {
            _content = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
            NSLog(@"content: %@",_content);
            loginInState = 102;
            if([self parseResult:_content])
            {
                [self shallowSave];
                [self.delegate finishedLoading];
                tryTime = 0;
            }
            else
            {
                if(tryTime < 3)
                {
                    [self login];
                }
                else
                {
                    NSError *error = [[NSError alloc] initWithDomain:@"UnknownFormat" code:0 userInfo:nil];
                    [self.delegate errorLoading:error];
                }
                tryTime++;
                ///TODO error error type
            }
        }
        else
        {
            loginInState ++;
        }

    }
    else
    {
        tempContent = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
        tempBriefContent = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText;"];
        detailGetting = NO;
    }
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}


#pragma mark NewsFeedProtocal delegate

-(void)start
{
    [self login];
}



-(BOOL)retreiveDetailForUrl:(NSString*)url
{
    if(loginInState < 100 || detailGetting == YES)
    {
        return NO;
    }
    detailGetting = YES;
    
    NSString *urlToGo = @"http://xuanke.tongji.edu.cn/tj_public/jsp/tongzhi.jsp?id='URL'";
    urlToGo = [urlToGo stringByReplacingOccurrencesOfString:@"URL" withString:url];
    
    [self loadWebPageWithString:urlToGo];
    
    while(detailGetting);
    
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(url == %@)", url]];
    
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
    news.content = tempContent;
    tempBriefContent =  [tempBriefContent stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    tempBriefContent =  [tempBriefContent stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    tempBriefContent =  [tempBriefContent stringByReplacingOccurrencesOfString: news.title withString:@""];
    tempBriefContent =  [tempBriefContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //tempBriefContent = [tempBriefContent substringFromIndex:news.title.length];
    news.briefcontent = tempBriefContent;
    NSLog(@"URL:%@ Content:%@",url,tempBriefContent);
    [[MyDataStorage instance] saveContext];
    detailGetting = NO;
    return YES;
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
    
    dispatch_async(kBgQueue, ^{
        for(News* item in matching)
        {
            if(item.content == nil && [item.category.name isEqualToString:[self catagoryForNews]])
            {
                [self retreiveDetailForUrl:item.url];
            }
        }
        //[self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
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

-(NSString*)catagoryForNews
{
    return @"选课网通知";
}

#pragma mark 
- (BOOL)hasFinishedLoading
{
    return loginInState >= 101;
}

@end
