//
//  ZhongDeNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 13-1-7.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "ZhongDeNewsModel.h"
#import "News.h"
#import "Category.h"
#import "MyDataStorage.h"
#import "SettingModal.h"
#import "ReachabilityChecker.h"
#import "MWFeedItem.h"
#import "NSString+HTML.h"
#import "DataOperator.h"
#import "SettingModal.h"
#import "UIApplication+Toast.h"
#import "NSNotificationCenter+Xuanke.h"


@implementation ZhongDeNewsModel

-(NSString*)rssURL
{
    return @"http://cdhawjw.blog.163.com/rss";
}

-(NSString*)safariLink:(News*)aNews
{
    return aNews.url;
}

@end
