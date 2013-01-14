//
//  DummyNewsModel.h
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsFeedProtocal.h"
#import "NewsLoaderProtocal.h"

@interface DummyNewsModel : NSObject <NewsFeedProtocal>
{
    NSDate *lastUpdateStart;
    NSDate *lastUpdateEnd;
}

@property (nonatomic) int categoryIndex;
@property (nonatomic) id<NewsLoaderProtocal> delegate;

-(BOOL)shouldSaveThisNewsWithThisDate:(NSDate*)date;
-(News*)newsForURL:(NSString*)url;
-(NSString*)concreateForBreif:(NSString*)briefContentToSave;

@end
