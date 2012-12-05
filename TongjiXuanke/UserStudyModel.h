//
//  UserStudyModel.h
//  TongjiXuanke
//
//  Created by Song on 12-12-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UserStudyModel : NSObject<UIWebViewDelegate>
{
    UIWebView *webView;
    NSTimer* timer;
}

+(UserStudyModel*)instance;
@end
