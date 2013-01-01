//
//  UIBarButtonItem+Addtion.h
//  TongjiXuanke
//
//  Created by Song on 12-10-15.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Addtion)

+ (UIBarButtonItem *)getFunctionButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)getBackButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)getActivityIndicatorButtonItem;

@end
