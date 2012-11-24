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

@interface Brain : NSObject<NewsLoaderProtocal>
{
    BOOL hasAPNSResubscribed;
    NSMutableArray *classArray;
    NSMutableArray *updateArray;
}
+ (Brain*)instance;

- (void)APNSStart;

- (void)configureClasses;

- (void)refresh;

@property (nonatomic,readonly) BOOL refreshing;

@end
