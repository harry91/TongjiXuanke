//
//  SettingModal.m
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SettingModal.h"

@implementation SettingModal


SettingModal* _settinginstance;

-(id)init
{
    if(self = [super init])
    {
        categorys = @[
            @{@"id" : @2 , @"name" : @"选课网"},
            @{@"id" : @3 , @"name" : @"软件学院"}
        ];
    }
    return self;
}

+(SettingModal*)instance
{
    if(!_settinginstance)
    {
        _settinginstance = [[SettingModal alloc] init];
    }
    return _settinginstance;
}

-(BOOL)shouldDownloadAllContentWithoutWIFI
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:@"shouldDownloadAllContentWithoutWIFI"];
}

-(void)setShouldDownloadAllContentWithoutWIFI:(BOOL)value
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:value forKey:@"shouldDownloadAllContentWithoutWIFI"];
    [ud synchronize];
}

-(int)autoCleanInterval
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud integerForKey:@"autoCleanInterval"];
}

-(void)setAutoCleanInterval:(int)value;
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:value forKey:@"autoCleanInterval"];
    [ud synchronize];
}


-(int)numberOfCategory
{
    return [categorys count];
}

-(NSString*) nameForCategoryAtIndex:(int)index
{
    return categorys[index][@"name"];
}

-(int)serverIDForCategoryAtIndex:(int)index
{
    NSNumber *num = categorys[index][@"id"];
    return [num integerValue];
}

-(BOOL)hasSubscribleCategoryAtIndex:(int)index
{
    return YES;
}

-(BOOL)setSubscribleCategoryAtIndex:(int)index to:(BOOL)value
{
    return YES;
}



@end
