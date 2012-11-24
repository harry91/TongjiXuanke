//
//  DummyNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "SettingModal.h"

@implementation DummyNewsModel
-(void)start
{
    if(lastUpdateEnd)
    {
        NSDate *now = [NSDate date];
        double deltaSeconds = fabs([lastUpdateEnd timeIntervalSinceDate:now]);
        double deltaMinutes = deltaSeconds / 60.0f;
        if(deltaMinutes < 20)
        {
            return;
        }
        else
        {
            lastUpdateStart = [NSDate date];
            [self realStart];
            return;
        }
    }
    [self performSelector:@selector(OhYeah) withObject:nil afterDelay:1];
//    if(lastUpdateStart && !lastUpdateEnd)
//    {
//    }
//    else
//    {
//        if(!lastUpdateStart)
//        {
//            lastUpdateStart = [NSDate date];
//            [self realStart];
//        }
//    }
}

-(void)OhYeah
{
    [self.delegate finishedLoadingInCategory:self.categoryIndex];
}

-(void)realStart
{
    [self.delegate finishedLoadingInCategory:self.categoryIndex];
}

-(void)retreiveDetails
{
    
}

-(BOOL)retreiveDetailForUrl:(NSString*)url
{
    return YES;
}

-(int)totalNewsCount
{
    return 0;
}

-(NSString*)titleForNewsIndex:(int)index
{
    return nil;
}

-(NSString*)contentForNewsIndex:(int)index
{
    return nil;
}

-(NSString*)idForNewsIndex:(int)index
{
    return nil;
}
-(NSDate*)timeForNewsIndex:(int)index
{
    return nil;
}
-(NSString*) catagoryForNews
{
    if( [NSStringFromClass(self.class) isEqualToString:@"DummyNewsModel"])
    {
        return nil;
    }
    return [[SettingModal instance] nameForCategoryAtIndex:self.categoryIndex];
}

@end
