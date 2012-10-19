//
//  SSEModel.h
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsFeedProtocal.h"
#import "NewsLoaderProtocal.h"
#import "MWFeedParser.h"

@interface SSEModel : NSObject <UIWebViewDelegate,NewsFeedProtocal,MWFeedParserDelegate>
{
    UIWebView *_webView;
    MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
    
    NSString *curl;
    NSString *tempContent;
    NSString *tempBriefContent;
    BOOL isgetting;
    NSMutableArray *urlToRetireve;
}

@property (nonatomic) id<NewsLoaderProtocal> delegate;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* password;

@end
