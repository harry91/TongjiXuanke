//
//  NSNotificationCenter+Xuanke.m
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NSNotificationCenter+Xuanke.h"

#define kAllUpdateDoneNotification @"kAllUpdateDoneNotification"


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


@end

