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
#import "LogInModal.h"
#import "NSString+URLRequest.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 


@interface XuankeModel : NSObject <UIWebViewDelegate,NewsFeedProtocal,NewsLoaderProtocal>
{
    UIWebView *_listView;
    UIWebView *_detailView;
    
    NSString *_content;
    NSMutableArray *dict;
    NSString *tempContent;
    NSString *tempBriefContent;
    
    BOOL isRetreivingThreadRunning;
    BOOL detailGetting;
    
    NSMutableArray *urlToRetireve;
    
    LogInModal *loginModal;
    BOOL logined;
    int tryTime;
}
@property (nonatomic) id<NewsLoaderProtocal> delegate;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* password;


@end
