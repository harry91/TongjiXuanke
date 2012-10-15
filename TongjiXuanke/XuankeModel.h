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

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 


@interface XuankeModel : NSObject <UIWebViewDelegate,NewsFeedProtocal>
{
    UIWebView *_webView;
    int loginInState;
    NSString *_content;
    NSMutableArray *dict;
    int tryTime;
    BOOL detailGetting;
    NSString *tempContent;
    NSString *tempBriefContent;
}
@property (nonatomic) id<NewsLoaderProtocal> delegate;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* password;


- (BOOL)hasFinishedLoading;


@end
