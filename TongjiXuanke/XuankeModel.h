//
//  XuankeModel.h
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NewsFeedProtocal.h"
#import "NewsLoaderProtocal.h"

@interface XuankeModel : NSObject <UIWebViewDelegate,NewsFeedProtocal>
{
    UIWebView *_webView;
    int loginInState;
    NSString *_content;
    NSMutableArray *dict;
    int tryTime;
}
@property (nonatomic) id<NewsLoaderProtocal> delegate;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* password;


- (BOOL)hasFinishedLoading;


@end
