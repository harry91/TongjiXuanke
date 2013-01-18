//
//  NSNotificationCenter+Xuanke.h
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
@class News;
@interface NSNotificationCenter (Xuanke)
+ (void)postAllUpdateDoneNotification;
+ (void)registerAllUpdateDoneNotificationWithSelector:(SEL)aSelector target:(id)aTarget;

+ (void)postUserCheckFailNotification;
+ (void)registerUserCheckFailNotificationWithSelector:(SEL)aSelector target:(id)aTarget;

+ (void)postCategoryChangedNotification;
+ (void)registerCategoryChangedNotificationWithSelector:(SEL)aSelector target:(id)aTarget;

+ (void)postCountChangedNotification;
+ (void)registerCountChangedNotificationWithSelector:(SEL)aSelector target:(id)aTarget;

+ (void)postFoundPersenalInfoInNewsNotification:(News*)news;
+ (void)registerFoundPersenalInfoInNewsNotificationWithSelector:(SEL)aSelector target:(id)aTarget;


@end
