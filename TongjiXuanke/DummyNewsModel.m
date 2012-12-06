//
//  DummyNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 12-11-24.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "SettingModal.h"
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
            [self performSelector:@selector(OhYeah) withObject:nil afterDelay:1];
            return;
        }
        else
        {
            lastUpdateStart = [NSDate date];
            [self realStart];
            return;
        }
    }
    else
    {
        if(!lastUpdateStart)
        {
            lastUpdateStart = [NSDate date];
            [self realStart];
            return;
        }
        else
        {
            [self performSelector:@selector(OhYeah) withObject:nil afterDelay:1];
            return;
        }
    }
}

-(void)OhYeah
{
    [self.delegate finishedLoadingInCategory:self.categoryIndex];
    
    //[self retreiveDetails];
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

-(BOOL)shouldSaveThisNewsWithThisDate:(NSDate*)theDate
{
    if([[SettingModal instance] autoCleanInterval] == 0)
        return YES;
    else
    {
        NSDate *now = [NSDate date];
        double deltaSeconds = fabs([theDate timeIntervalSinceDate:now]);
        double deltaMinutes = deltaSeconds / 60.0f;
        int monthAgo = (int)floor(deltaMinutes/(60 * 24 * 30));
        if(monthAgo >= [[SettingModal instance] autoCleanInterval])
            return NO;
    }
    return YES;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSURL *theRessourcesURL = [request URL];
    NSString *fileExtension = [theRessourcesURL pathExtension];
    
    if (([fileExtension compare:@"mp3" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"css" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"jpg" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"gif" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"png" options:NSCaseInsensitiveSearch] ==  NSOrderedSame))
    {
        if(fileExtension)
            return NO;
    }
    return YES;
}


@end
