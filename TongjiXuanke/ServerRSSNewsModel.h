//
//  ServerRSSNewsModel.h
//  TongjiXuanke
//
//  Created by Song on 12-12-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "NewsFeedProtocal.h"
#import "MWFeedParser.h"

@interface ServerRSSNewsModel : DummyNewsModel<NewsFeedProtocal,MWFeedParserDelegate>
{
    MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
    NSString *categoryOnServer;
}

@end
