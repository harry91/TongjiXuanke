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


@end
