//
//  XuankeModel.h
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NewsFeedProtocal.h"
#import "ParseNewsModel.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 


@interface XuankeModel : ParseNewsModel<NewsFeedProtocal>

@end
