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
#import "ServerRSSNewsModel.h"

@interface ZhongDeNewsModel : ServerRSSNewsModel<NewsFeedProtocal,MWFeedParserDelegate>


@end
