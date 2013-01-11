//
//  InternationalOfficeModel.h
//  TongjiXuanke
//
//  Created by Song on 12-12-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "NewsFeedProtocal.h"
#import "MWFeedParser.h"
#import "ServerRSSNewsModel.h"

@interface InternationalOfficeModel : ServerRSSNewsModel<MWFeedParserDelegate,NewsFeedProtocal>

@end
