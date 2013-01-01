//
//  StudentProfileGetter.h
//  TongjiXuanke
//
//  Created by Song on 12-11-29.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentProfileGetter : NSObject<UIWebViewDelegate>
{
    UIWebView *_webView;
}

-(void)start;

@end
