//
//  SettingModal.h
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModal : NSObject
{
    NSArray *categorys;
    NSMutableArray *subscribledIndex;
}

+(SettingModal*)instance;

-(BOOL)shouldDownloadAllContentWithoutWIFI;
-(void)setShouldDownloadAllContentWithoutWIFI:(BOOL)value;

-(int)autoCleanInterval;
-(void)setAutoCleanInterval:(int)value;

-(int)numberOfCategory;
-(NSString*) nameForCategoryAtIndex:(int)index;
-(int)serverIDForCategoryAtIndex:(int)index;

-(BOOL)hasSubscribleCategoryAtIndex:(int)index;
-(BOOL)setSubscribleCategoryAtIndex:(int)index to:(BOOL)value;
-(int)subscribledCount;

@end
