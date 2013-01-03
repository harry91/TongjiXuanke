//
//  UIWebView+HighlightWebView.h
//  TongjiXuanke
//
//  Created by Song on 13-1-3.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (HighlightWebView)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;
@end
