//
//  SettingModal.m
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SettingModal.h"
#import "APNSManager.h"
#import "NSString+EncryptAndDecrypt.h"
#import "UIDevice+IdentifierAddition.h"

@implementation SettingModal


SettingModal* _settinginstance;

-(id)init
{
    if(self = [super init])
    {
        categorys = @[
        @{@"id" : @1 , @"name" : @"系统消息",    @"class" : @"SystemNewsModel" ,@"baseURL" : @"http://sbhhbs.com/" },
        @{@"id" : @2 , @"name" : @"选课网",    @"class" : @"XuankeModel" ,@"baseURL" : @"http://xuanke.tongji.edu.cn/" },
        @{@"id" : @3 , @"name" : @"软件学院",  @"class" : @"SSEModel" ,@"baseURL" : @"http://sse.tongji.edu.cn/Notice/"}
        ];
        
        subscribledIndex = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"selectedCategoryArray"] mutableCopy];
        
        _isProVersion = NO;
        UIDevice *dev = [UIDevice currentDevice];
        NSString *deviceUuid = [dev uniqueGlobalDeviceIdentifier];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *ProVersion = [ud objectForKey:@"ProVersion"];
        ProVersion = [NSString stringByDecryptString:ProVersion];
        if([deviceUuid isEqualToString:ProVersion])
        {
            _isProVersion = YES;
        }
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

-(int)indexOfCategoryWithName:(NSString*)str
{
    for(int i = 0; i < categorys.count; i ++)
    {
        if([categorys[i][@"name"] isEqualToString:str])
        {
            return i;
        }
    }
    return -1;
}

-(NSString*) classStringForCategoryAtIndex:(int)index
{
    return categorys[index][@"class"];
}

-(NSString*) baseURLStringForCategoryAtIndex:(int)index
{
    return categorys[index][@"baseURL"];
}

-(int)serverIDForCategoryAtIndex:(int)index
{
    NSNumber *num = categorys[index][@"id"];
    return [num integerValue];
}

-(BOOL)hasSubscribleCategoryAtIndex:(int)index
{
    for(NSNumber *n in subscribledIndex)
    {
        int num = [n integerValue];
        if(num == index)
            return YES;
    }
    return NO;
}

-(int)subscribledCount
{
    return subscribledIndex.count;
}

-(BOOL)setSubscribleCategoryAtIndex:(int)index to:(BOOL)value
{
    BOOL result;
    if(value)
    {
        if(![self hasSubscribleCategoryAtIndex:index])
        {
            [subscribledIndex addObject:[NSNumber numberWithInt:index]];
        }
    }
    else
    {
        for(int i = 0; i < subscribledIndex.count; i++)
        {
            NSNumber *n = subscribledIndex[i];
            int num = [n integerValue];
            if(num == index)
                [subscribledIndex removeObjectAtIndex:i];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:subscribledIndex forKey:@"selectedCategoryArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(value)
    {
        result = [APNSManager subscribleCategory:[self serverIDForCategoryAtIndex:index]];
    }
    else
    {
        result = [APNSManager desubscribleCategory:[self serverIDForCategoryAtIndex:index]];
    }
    return result;
}

-(void)goPro
{
    if(self.isProVersion)
        return;
    UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [dev uniqueGlobalDeviceIdentifier];
    deviceUuid = [NSString stringByEncryptString:deviceUuid];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setObject:deviceUuid forKey:@"ProVersion"];
    [ud synchronize];
    _isProVersion = YES;
}

-(int)needHelp
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud objectForKey:@"Help"])
    {
        NSNumber *n = [ud objectForKey:@"Help"];
        if([n integerValue] < 3)//first help 3 pages
            return 0;
        else
            return -1;
    }
    return 0;
}

-(void)finishTourialWithProgress:(int)progress
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [NSNumber numberWithInt:progress];
    [ud setObject:num forKey:@"Help"];
    [ud synchronize];
}

-(BOOL)hasStudentProfileSet
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if([ud objectForKey:@"studentName"])
    {
        return YES;
    }
    return NO;
}
-(void)setStudentProfileWithName:(NSString*)name department:(NSString*)department Major:(NSString*)major
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if(name)
        [ud setObject:name forKey:@"studentName"];
    if(department)
        [ud setObject:name forKey:@"department"];
    if(major)
        [ud setObject:name forKey:@"major"];
    [ud synchronize];
}
-(NSString*)studentName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"studentName"];
}
-(NSString*)studentDepartment
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"department"];
}

-(NSString*)studentMajor
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"major"];
}


-(void)doLogoutCleanUp
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"studentName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"department"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"major"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}


@end
