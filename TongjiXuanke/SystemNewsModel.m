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

@end
