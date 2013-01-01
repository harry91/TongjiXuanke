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
#import "ServerRSSNewsModel.h"

@interface SystemNewsModel : ServerRSSNewsModel<NewsFeedProtocal,MWFeedParserDelegate>

@end
