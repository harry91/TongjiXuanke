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
    return NO;
}

@end
