//
//  CAUPNewsModel.h
//  TongjiXuanke
//
//  Created by Song on 12-12-6.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "NewsFeedProtocal.h"
#import "NewsLoaderProtocal.h"

@interface CAUPNewsModel : DummyNewsModel<UIWebViewDelegate,NewsFeedProtocal>
{
    NSMutableArray *dict;
    UIWebView *webview;
    NSString *tempContent;
    NSString *tempBriefContent;
    BOOL isgetting;
    NSString *curl;
    NSMutableArray *urlToRetireve;
    float timeToWait;
    BOOL iamwaiting;
}

@end
