//
//  SystemNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 12-11-25.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SystemNewsModel.h"
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

@implementation SystemNewsModel

-(id)init
{
    if(self = [super init])
    {
        categoryOnServer = @"system";
    }
    return self;
}


-(void)save
{
    for(int i = 0; i <[self totalNewsCount]; i++)
    {
        FakeNews *news = [[FakeNews alloc] init];
        news.title = [self titleForNewsIndex:i];
        
        news.briefcontent = nil;
        
        MWFeedItem *item = parsedItems[i];
        if (item) {
            // Process
            NSString *itemTitle = item.summary;
            news.briefcontent = [itemTitle stringByConvertingHTMLToPlainText];
            
            NSMutableString *source = [item.summary mutableCopy];
            NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"newsdetail" ofType:@"html"];
            NSString *infoText = [[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
            news.content = [infoText stringByReplacingOccurrencesOfString:@"@#Content#@" withString:source];
        }
        
        news.date = [self timeForNewsIndex:i];
        news.favorated = NO;
        news.haveread = NO;
        news.url = [self idForNewsIndex:i];
        if([news.url isEqualToString:@"http://sbhhbs.com/tjtzzzd/rss/?e=1"])
        {
            news.url = @"http://sbhhbs.com/tjtzzzd/news/1.html";
        }
        
        [[DataOperator instance] distinctSave:news inCategory:[self catagoryForNews]];
    }
}


@end
