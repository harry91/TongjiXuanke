//
//  InternationalOfficeModel.m
//  TongjiXuanke
//
//  Created by Song on 12-12-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "InternationalOfficeModel.h"
#import "DataOperator.h"

@implementation InternationalOfficeModel


#pragma mark News Feed Protocal

-(NSString*)rssURL
{
    return @"http://sbhhbs.com:7779/";
}

-(NSString*)safariLink:(News*)aNews
{
    return [@"http://www.tongji-uni.com/newsshow.aspx?sn=" stringByAppendingString:aNews.url];
}

@end
