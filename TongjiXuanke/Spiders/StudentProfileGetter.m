//
//  StudentProfileGetter.m
//  TongjiXuanke
//
//  Created by Song on 12-11-29.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "StudentProfileGetter.h"
#import "NSString+URLRequest.h"
#import "SettingModal.h"

@implementation StudentProfileGetter

-(id)init
{
    if(self = [super init])
    {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        
    }
    return self;
}

-(void)start
{
    [_webView loadRequest:[@"http://xuanke.tongji.edu.cn/tj_login/info.jsp" convertToURLRequest]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *content = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    NSLog(@"content: %@",content);
    //<b>学号</b>：102890&nbsp;&nbsp;<b>姓名</b>：宋帛衡&nbsp;&nbsp;<b>学期</b>：5&nbsp;&nbsp;<b>院系</b>：软件学院&nbsp;&nbsp;<b>专业</b>：软件工程&nbsp;&nbsp;
    @try {
        NSRange range = [content rangeOfString:@"<b>姓名</b>："];
        if(range.location == NSNotFound)
            return;
        content = [content substringFromIndex:range.location + range.length];
        range = [content rangeOfString:@"&nbsp;&nbsp"];
        NSString *name = [content substringToIndex:range.location];
        
        range = [content rangeOfString:@"<b>院系</b>："];
        if(range.location == NSNotFound)
            return;
        content = [content substringFromIndex:range.location + range.length];
        range = [content rangeOfString:@"&nbsp;&nbsp"];
        NSString *department = [content substringToIndex:range.location];
        
        range = [content rangeOfString:@"<b>专业</b>："];
        if(range.location == NSNotFound)
            return;
        content = [content substringFromIndex:range.location + range.length];
        range = [content rangeOfString:@"&nbsp;&nbsp"];
        NSString *major = [content substringToIndex:range.location];
        
        [SettingModal instance].studentName = name;
        [SettingModal instance].studentDepartment = department;
        [SettingModal instance].studentMajor = major;
    }
    @catch (NSException *exception) {
        NSLog(@"Student Profile Getter Failed!");
    }
    @finally {
        ;
    }
   
}

@end
