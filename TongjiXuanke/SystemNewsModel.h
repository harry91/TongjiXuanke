//
//  SystemNewsModel.h
//  TongjiXuanke
//
//  Created by Song on 12-11-25.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "NewsFeedProtocal.h"
#import "MWFeedParser.h"

@interface SystemNewsModel : DummyNewsModel<UIWebViewDelegate,NewsFeedProtocal,MWFeedParserDelegate>
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
@end
