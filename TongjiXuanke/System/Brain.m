//
//  Brain.m
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "Brain.h"
#import "DummyNewsModel.h"
#import "NSNotificationCenter+Xuanke.h"
#import "ReachabilityChecker.h"
#import "NSNotificationCenter+Xuanke.h"
#import "DataOperator.h"

@implementation Brain


Brain* _brainInstance = nil;

-(id)init
{
    if(self = [super init])
    {
        hasAPNSResubscribed = NO;
        [self configureClasses];
        updateArray = [@[] mutableCopy];
        SettingModal *instance = [SettingModal instance];
        for (int i = 0; i < [instance numberOfCategory]; i++) {
            [updateArray addObject:@"ready"];
        }
        [[DataOperator instance] cleanUpExpireNews];
        [NSNotificationCenter registerCategoryChangedNotificationWithSelector:@selector(configureClasses) target:self];
        
        userStudy = [UserStudyModel instance];
    }
    return self;
}

+(Brain*)instance
{
    if(!_brainInstance)
    {
        _brainInstance = [[Brain alloc] init];
    }
    return _brainInstance;
}

- (void)APNSThread
{
    [APNSManager reSubscrible];
}


- (void)APNSProcess
{
    [self performSelectorInBackground:@selector(APNSThread) withObject:nil];
    [APNSManager cleanBadge];

}

- (void)APNSStart
{
    if(hasAPNSResubscribed)
        return;
    hasAPNSResubscribed = YES;
    [APNSManager requestAPNS];
    [self performSelector:@selector(APNSProcess) withObject:nil afterDelay:5];
}

- (void)configureClasses
{
    BOOL initing = NO;
    if(classArray == nil)
    {
        classArray = [@[] mutableCopy];
        initing = YES;
    }
    
    SettingModal *instance = [SettingModal instance];
    for (int i = 0; i < [instance numberOfCategory]; i++) {
            if(initing)
            {
                Class class;
                if([instance hasSubscribleCategoryAtIndex:i])
                {
                    class = NSClassFromString([instance classStringForCategoryAtIndex:i]);
                }
                else
                {
                    class = NSClassFromString(@"DummyNewsModel");
                }
                id anInstance = [[class alloc] init];
                [classArray addObject:anInstance];

            }
            else{
                NSString *className = NSStringFromClass([classArray[i] class]);
                if([className isEqualToString:@"DummyNewsModel"])
                {
                    if([instance hasSubscribleCategoryAtIndex:i])
                    {
                        Class class = NSClassFromString([instance classStringForCategoryAtIndex:i]);
                        id anInstance = [[class alloc] init];
                        classArray[i] = anInstance;
                    }
                }
                else
                {
                    if(![instance hasSubscribleCategoryAtIndex:i])
                    {
                        Class class = NSClassFromString(@"DummyNewsModel");
                        id anInstance = [[class alloc] init];
                        classArray[i] = anInstance;
                    }
                }
            }
        }
}

- (void)refresh
{
    if(![[ReachabilityChecker instance] hasInternetAccess])
    {
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if(![ud objectForKey:@"password"])
    {
        return;
    }
    
    SettingModal *instance = [SettingModal instance];
    for (int i = 0; i < [instance numberOfCategory]; i++)
    {
        DummyNewsModel *anFeed = classArray[i];
        anFeed.categoryIndex = i;
        anFeed.delegate = self;
        [anFeed start];
        updateArray[i] = @"updating";
    }
    _refreshing = YES;
}


- (void)requestedNewsWithCategoryIndex:(int)index url:(NSString*)url
{
    DummyNewsModel *anFeed = classArray[index];
    [anFeed retreiveDetailForUrl:url];
}

- (BOOL)allUpdateDone
{
    for(NSString *str in updateArray)
    {
        if([str isEqualToString:@"updating"])
        {
            return NO;
        }
    }
    return YES;
}

- (void)checkUpdate
{
    if([self allUpdateDone])
    {
        _refreshing = NO;
        [NSNotificationCenter postAllUpdateDoneNotification];
    }
}

- (void)getDetails:(int)categoryIndex
{
    if([[ReachabilityChecker instance] hasInternetAccess])
    {
        if([[ReachabilityChecker instance] usingWIFI] || [[SettingModal instance] shouldDownloadAllContentWithoutWIFI])
        {
            DummyNewsModel *anFeed = classArray[categoryIndex];
            [anFeed retreiveDetails];
        }
    }
}

- (id<NewsFeedProtocal>) instanceOfCategoryAtIndex:(int)index
{
    return classArray[index];
}

#pragma mark News Loader Protocal
-(void)finishedLoadingInCategory:(int)categoryIndex
{
    updateArray[categoryIndex] = @"done";
    [self checkUpdate];
    [self getDetails:categoryIndex];
}

-(void)errorLoading:(NSError*)error inCategory:(int)categoryIndex
{
    updateArray[categoryIndex] = @"error";
    [self checkUpdate];
}


@end
