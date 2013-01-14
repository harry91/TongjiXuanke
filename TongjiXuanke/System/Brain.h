//
//  Brain.h
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APNSManager.h"
#import "SettingModal.h"
#import "NewsLoaderProtocal.h"
#import <Parse/Parse.h>
#import "UserStudyModel.h"
#import "NewsFeedProtocal.h"
@interface Brain : NSObject<NewsLoaderProtocal>
{
    BOOL hasAPNSResubscribed;
    NSMutableArray *classArray;
    NSMutableArray *updateArray;
    UserStudyModel *userStudy;
}
+ (Brain*)instance;

- (void)APNSStart;

- (void)configureClasses;

- (void)refresh;

- (void)requestedNewsWithCategoryIndex:(int)index url:(NSString*)url;

- (id<NewsFeedProtocal>) instanceOfCategoryAtIndex:(int)index;

@property (nonatomic,readonly) BOOL refreshing;

- (void)resetTimer;

@end
