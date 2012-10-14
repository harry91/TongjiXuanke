//
//  XuankeModel.m
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "XuankeModel.h"

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
    }
    return self;
}

-(void)setDelegate:(id<NewsLoaderProtocal>)delegate
{
    _delegate = delegate;
    [self login];
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


#pragma mark UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *currentURL = _webView.request.URL.absoluteString;
    
    NSLog(@"Finish loading: %@",currentURL);
    NSLog(@"state: %d",loginInState);
    
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}


#pragma mark NewsFeedProtocal delegate


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

-(NSString*)timeForNewsIndex:(int)index
{
    NSString *dateStr = dict[index][@"ID"];
    dateStr = [dateStr substringWithRange:NSMakeRange(0,8)];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd"];
    NSDate *myDate = [df dateFromString: dateStr];
    
    
    // Your dates:
    NSDate * today = [NSDate date];
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400]; //86400 is the seconds in a day
    NSDate * refDate = myDate; // your reference date
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * refDateString = [[refDate description] substringToIndex:10];
    
    NSString* result;
    
    if ([refDateString isEqualToString:todayString])
    {
        result =  @"今天";
    } else if ([refDateString isEqualToString:yesterdayString])
    {
        result =  @"昨天";
    } else 
    {
        result =  refDateString;
    }
    
    return result;
}

-(NSString*)catagoryForNewsIndex:(int)index
{
    return @"选课网通知";
}

#pragma mark 
- (BOOL)hasFinishedLoading
{
    return loginInState >= 101;
}

@end
