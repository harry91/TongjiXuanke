//
//  UIApplication+Toast.m
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "UIApplication+Toast.h"
#import "OLGhostAlertView.h"

@implementation UIApplication (Toast)

int _NetworkIndicatorCount = 0;

+ (void)presentToast:(NSString *)text
{
    OLGhostAlertView *ghastly = [[OLGhostAlertView alloc] initWithTitle:text];
    [ghastly show];
}

- (void)showNetworkIndicator
{
    _NetworkIndicatorCount++;
    self.networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkIndicator
{
    _NetworkIndicatorCount--;
    if(_NetworkIndicatorCount <= 0)
    {
        _NetworkIndicatorCount = 0;
        self.networkActivityIndicatorVisible = NO;
    }
}

@end
