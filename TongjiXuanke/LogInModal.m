//
//  LogInModal.m
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "LogInModal.h"
#import "NSNotificationCenter+Xuanke.h"

@implementation LogInModal

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
        finished = NO;
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
}



#pragma mark UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *currentURL = _webView.request.URL.absoluteString;
    
    NSLog(@"start loading: %@",currentURL);
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *currentURL = _webView.request.URL.absoluteString;
    if(loginInState == 1 && [currentURL isEqualToString:@"http://tjis2.tongji.edu.cn:58080/amserver/UI/Login"])
    {
        NSError *error = [[NSError alloc] initWithDomain:@"AccountOrPwdInvalid" code:0 userInfo:nil];
        [NSNotificationCenter postUserCheckFailNotification];
        [self.delegate LoginFailWithError:error];
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
    else if(loginInState >= 1)
    {
        if(!finished)
        {
            [self.delegate LoginSuccess];
            finished = YES;
        }
    }
    else
    {
        loginInState ++;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",error);
    [self.delegate LoginFailWithError:error];
}


#pragma mark NewsFeedProtocal delegate

-(void)start
{
    [self login];
}


@end
