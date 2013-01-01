//
//  NSNotificationCenter+Xuanke.m
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NSNotificationCenter+Xuanke.h"

#define kAllUpdateDoneNotification @"kAllUpdateDoneNotification"
#define kUserCheckFailNotification @"kUserCheckFailNotification"
#define kCategoryChangedNotification @"kCategoryChangedNotification"
#define kFoundPersenalInfoInNews @"kFoundPersenalInfoInNews"


@implementation NSNotificationCenter (Xuanke)
+ (void)postAllUpdateDoneNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAllUpdateDoneNotification object:nil userInfo:nil];
}

+ (void)registerAllUpdateDoneNotificationWithSelector:(SEL)aSelector target:(id)aTarget
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kAllUpdateDoneNotification
                 object:nil];
}

+ (void)postUserCheckFailNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserCheckFailNotification object:nil userInfo:nil];
}

+ (void)registerUserCheckFailNotificationWithSelector:(SEL)aSelector target:(id)aTarget
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kUserCheckFailNotification
                 object:nil];
}


+ (void)postCategoryChangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryChangedNotification object:nil userInfo:nil];

}

+ (void)registerCategoryChangedNotificationWithSelector:(SEL)aSelector target:(id)aTarget
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kCategoryChangedNotification
                 object:nil];
}


+ (void)postFoundPersenalInfoInNewsNotification:(News*)news;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFoundPersenalInfoInNews object:news userInfo:nil];
}

+ (void)registerFoundPersenalInfoInNewsNotificationWithSelector:(SEL)aSelector target:(id)aTarget
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kFoundPersenalInfoInNews
                 object:nil];
}


@end

