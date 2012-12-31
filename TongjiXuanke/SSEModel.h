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
#import "DummyNewsModel.h"

@interface SSEModel : DummyNewsModel <UIWebViewDelegate,NewsFeedProtocal,MWFeedParserDelegate>
{
    MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
}

@end
