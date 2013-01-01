//
//  UISearchBar+CustomLeftView.m
//  JCAutocompletingSearchDemo
//
//  Created by Song on 13-1-1.
//  Copyright (c) 2013年 James Coleman. All rights reserved.
//

#import "UISearchBar+CustomLeftView.h"

@implementation UISearchBar (CustomLeftView)

-(void)setSearchIconView:(UIView*)leftView
{
    UITextField *searchField = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchField = (UITextField *)subview;
            break;
        }
    }
    
    if (searchField) {
        searchField.leftView = leftView;
    }
}

@end
