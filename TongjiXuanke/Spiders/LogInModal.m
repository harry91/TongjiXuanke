//
//  LogInModal.m
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "LogInModal.h"
#import "NSNotificationCenter+Xuanke.h"
#import "UIApplication+Toast.h"
#import "SettingModal.h"
#import "NSString+URLRequest.h"

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


//- (void)loadWebPageWithString:(NSString*)urlString
//{
//    NSURL *url =[NSURL URLWithString:urlString];
//    NSURLRequest *request =[NSURLRequest requestWithURL:url];
//    [_webView loadRequest:request];
//}


-(void)login
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    [_webView loadRequest:[@"http://tjis2.tongji.edu.cn:58080/amserver/UI/Login?goto=http%3A%2F%2Fxuanke.tongji.edu.cn%2Fpass.jsp" convertToURLRequest]];
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
        [[UIApplication sharedApplication] hideNetworkIndicator];
        [self.delegate LoginFailWithError:error];
    }
    else if(loginInState == 0)
    {
        NSString *fillUserName = @"document.frm1.IDToken1.value='USERNAME';";
        NSString *fillPwd = @"document.frm2.IDToken2.value='PASSWORD';";
        @try {
            fillUserName = [fillUserName stringByReplacingOccurrencesOfString:@"USERNAME" withString:self.userName];
            fillPwd = [fillPwd stringByReplacingOccurrencesOfString:@"PASSWORD" withString:self.password];
        }
        @catch (NSException *exception) {
            NSLog (@"Caught %@%@", [exception name], [exception reason]);
        }
        @finally {
            
        }
        
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
            [[UIApplication sharedApplication] hideNetworkIndicator];
            if(![[SettingModal instance] hasStudentProfileSet])
            {
                studentProfileGetter = [[StudentProfileGetter alloc] init];
                [studentProfileGetter start];
            }
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


-(BOOL)loggedIn
{
    return finished;
}

#pragma mark NewsFeedProtocal delegate

-(void)start
{
    [self login];
}


@end
