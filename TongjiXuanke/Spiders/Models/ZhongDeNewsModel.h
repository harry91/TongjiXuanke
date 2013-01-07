//
//  ZhongDeNewsModel.h
//  TongjiXuanke
//
//  Created by Song on 13-1-7.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "NewsFeedProtocal.h"
#import "MWFeedParser.h"

@interface ZhongDeNewsModel : DummyNewsModel<NewsFeedProtocal,MWFeedParserDelegate>
{
    MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
}

@end
