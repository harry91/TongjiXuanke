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

-(NSString*)rssURL
{
    return @"http://sbhhbs.com:7778/";
}

-(NSString*)safariLink:(News*)aNews
{
    return [@"http://old.tongji-caup.org/student/news_detail.asp?id=" stringByAppendingString:aNews.url];
}


@end
