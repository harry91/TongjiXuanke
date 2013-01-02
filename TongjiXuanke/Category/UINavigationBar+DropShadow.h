//
//  UINavigationBar+DropShadow.h
//  TongjiXuanke
//
//  Created by Song on 13-1-2.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (DropShadow)
- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity;
@end
