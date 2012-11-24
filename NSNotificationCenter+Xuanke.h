//
//  NSNotificationCenter+Xuanke.h
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Xuanke)
+ (void)postAllUpdateDoneNotification;
+ (void)registerAllUpdateDoneNotificationWithSelector:(SEL)aSelector target:(id)aTarget;


@end
