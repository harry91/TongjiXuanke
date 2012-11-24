//
//  UIApplication+Toast.h
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Toast)

+ (void)presentToast:(NSString *)text;

- (void)showNetworkIndicator;
- (void)hideNetworkIndicator;

@end
