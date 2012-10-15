//
//  UIBarButtonItem+Addtion.m
//  TongjiXuanke
//
//  Created by Song on 12-10-15.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "UIBarButtonItem+Addtion.h"

@implementation UIBarButtonItem (Addtion)

+ (UIButton *)getNavButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8f] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    if(target && action)
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}

+ (UIBarButtonItem *)getFunctionButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIBarButtonItem getNavButtonWithTitle:title target:target action:action];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithCustomView:button];
    return result;
}

+ (UIBarButtonItem *)getBackButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIBarButtonItem getNavButtonWithTitle:[NSString stringWithFormat:@"  %@", title] target:target action:action];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_back.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_back_hl.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithCustomView:button];
    return result;
}

+ (UIBarButtonItem *)getActivityIndicatorButtonItem {
    UIButton *button = [UIBarButtonItem getNavButtonWithTitle:@"" target:nil action:nil];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish.png"] forState:UIControlStateNormal];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = button.center;
    [button addSubview:indicator];
    [indicator startAnimating];
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithCustomView:button];
    return result;
}


@end
