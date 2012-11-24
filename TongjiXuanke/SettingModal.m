//
//  SettingModal.m
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SettingModal.h"
#import "APNSManager.h"

@implementation SettingModal


SettingModal* _settinginstance;

-(id)init
{
    if(self = [super init])
    {
        categorys = @[
        @{@"id" : @2 , @"name" : @"选课网",    @"class" : @"XuankeModel" ,@"baseURL" : @"http://sse.tongji.edu.cn/" },
        @{@"id" : @3 , @"name" : @"软件学院",  @"class" : @"SSEModel" ,@"baseURL" : @"http://xuanke.tongji.edu.cn/"}
        ];
        
        subscribledIndex = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"selectedCategoryArray"] mutableCopy];
        
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
        result = [APNSManager subscribleCategory:[self serverIDForCategoryAtIndex:index]];
    }
    else
    {
        result = [APNSManager desubscribleCategory:[self serverIDForCategoryAtIndex:index]];
    }
    if(result)
    {
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
    }
    return result;
}



@end
