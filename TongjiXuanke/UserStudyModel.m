//
//  UserStudyModel.m
//  TongjiXuanke
//
//  Created by Song on 12-12-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "UserStudyModel.h"
#import "NSString+URLRequest.h"

@implementation UserStudyModel
UserStudyModel* _userstudyinstance = nil;

-(id)init
{
    if(self = [super init])
    {
        webView = [[UIWebView alloc] init];
        webView.delegate = self;
        [webView loadRequest:[@"http://sbhhbs.com/tzzzd_stat.php" convertToURLRequest]];
        
        timer = [NSTimer scheduledTimerWithTimeInterval: 60 * 5
                                                 target: self
                                               selector: @selector(refresh)
                                               userInfo: nil
                                                repeats: YES];

    }
    return self;
}

-(void)refresh
{
    [webView loadRequest:[@"http://sbhhbs.com/tzzzd_stat.php" convertToURLRequest]];
}

+(UserStudyModel*)instance
{
    if(!_userstudyinstance)
    {
        _userstudyinstance = [[UserStudyModel alloc] init];
    }
    return _userstudyinstance;
}

@end
