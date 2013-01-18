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
#import "NSString+EncryptAndDecrypt.h"
#import "MyDataStorage.h"
#import "News.h"
#import "Category.h"
#import "DataOperator.h"
#import "NSNotificationCenter+Xuanke.h"

@implementation SettingModal


SettingModal* _settinginstance;

-(id)init
{
    if(self = [super init])
    {
        categorys = @[
        @{@"id" : @1 , @"name" : @"系统消息",    @"class" : @"SystemNewsModel" ,@"baseURL" : @"http://sbhhbs.com/", @"serverrss" : @YES },
        @{@"id" : @2 , @"name" : @"选课网",    @"class" : @"XuankeModel" ,@"baseURL" : @"http://xuanke.tongji.edu.cn/" , @"serverrss" : @NO },
        @{@"id" : @3 , @"name" : @"软件学院",  @"class" : @"SSEModel" ,@"baseURL" : @"http://sse.tongji.edu.cn/Notice/" , @"serverrss" : @NO },
        @{@"id" : @4 , @"name" : @"土木小站",  @"class" : @"TumuXiaozhanModel" ,@"baseURL" : @"http://sbhhbs.com/" , @"serverrss" : @YES },
        @{@"id" : @5 , @"name" : @"建筑与城市规划",  @"class" : @"CAUPNewsModel" ,@"baseURL" : @"http://old.tongji-caup.org/" , @"serverrss" : @NO },
        @{@"id" : @6 , @"name" : @"外事办",  @"class" : @"InternationalOfficeModel" ,@"baseURL" : @"http://www.tongji-uni.com/" , @"serverrss" : @NO },
        @{@"id" : @7 , @"name" : @"中德工程学院",  @"class" : @"ZhongDeNewsModel" ,@"baseURL" : @"http://cdhawjw.blog.163.com/" , @"serverrss" : @NO }
#ifndef __OPTIMIZE__
,@{@"id" : @999 , @"name" : @"测试",  @"class" : @"ServerRSSNewsModel" ,@"baseURL" : @"http://sbhhbs.com/" , @"serverrss" : @YES }
#endif
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

-(BOOL) isCategoryAtIndexServerRSS:(int)index
{
    NSNumber* num = categorys[index][@"serverrss"];
    return [num boolValue];
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
    //BOOL result;
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
    
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    dispatch_async(kBgQueue, ^{
        if(value)
        {
            [APNSManager subscribleCategory:[self serverIDForCategoryAtIndex:index]];
        }
        else
        {
           [APNSManager desubscribleCategory:[self serverIDForCategoryAtIndex:index]];
        }
    });
    return YES;//Buggy to always return true
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

-(NSString*)studentName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"studentName"];
}

-(void)setStudentName:(NSString*)name
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:name forKey:@"studentName"];
    [ud synchronize];
}

-(NSString*)studentDepartment
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"department"];
}
-(void)setStudentDepartment:(NSString*)department
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:department forKey:@"department"];
    [ud synchronize];
}

-(NSString*)studentMajor
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"major"];
}

-(void)setStudentMajor:(NSString*)major
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:major forKey:@"major"];
    [ud synchronize];
}

-(NSString*)studentID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
}

-(void)setStudentID:(NSString*)username
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:username forKey:@"username"];
    [ud synchronize];
}

-(NSString*)password
{
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if (pwd) {
        pwd = [NSString stringByDecryptString:pwd];
    }
    return pwd;
}

-(void)setPassword:(NSString *)password
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if(password)
        password = [NSString stringByEncryptString:password];
    [ud setObject:password forKey:@"password"];
    [ud synchronize];
}



-(NSArray*)searchHistory
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"searchHistory"];
}

-(void)didSearch:(NSString*)str
{
    if(str == nil || [str isEqualToString:@""])
        return;
    NSMutableArray *arr = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"searchHistory"] mutableCopy];
    if(!arr)
        arr = [@[] mutableCopy];
    
    for (NSString* s in arr)
    {
        if([s isEqualToString:str])
            return;
    }
    
    if(arr.count == 10)
        [arr removeObjectAtIndex:9];
    [arr insertObject:str atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"searchHistory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)doLogoutCleanUp
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"studentName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"department"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"major"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"searchHistory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma  mark

- (void)initCountingSystem
{
    countingSystem = [@[] mutableCopy];
    int totalFav,totalUnread;
    totalFav = 0;
    totalUnread = 0;
    for(int i = 0; i < [self numberOfCategory]; i++)
    {
        NSMutableDictionary *category = [@{} mutableCopy];
        category[@"text"] = [self nameForCategoryAtIndex:i];
        int unread = [self numberOfUnreadMessageInCategory:category[@"text"]];
        totalUnread += unread;
        category[@"unread"] = [NSNumber numberWithInt:unread];
        int fav = [self numberOfFavoritedMessageInCategory:category[@"text"]];
        totalFav += fav;
        category[@"fav"] = [NSNumber numberWithInt:fav];
        [countingSystem addObject:category];
    }
    
    NSMutableDictionary *category = [@{} mutableCopy];
    category[@"text"] = @"全部";
    category[@"unread"] = [NSNumber numberWithInt:totalUnread];
    category[@"fav"] = [NSNumber numberWithInt:totalFav];
    [countingSystem addObject:category];
}

- (NSArray*)listOfItem
{
    if(allNewsCache)
        return allNewsCache;
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    // Create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    
    NSString* categoryFilterString = [[DataOperator instance] allFilterClause];
    
    
    NSPredicate *simplePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(not (title == \"snow\")) and (%@)",categoryFilterString]];
    
    [fetchRequest setPredicate:simplePredicate];
    
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!matching)
    {
        NSLog(@"Error: %@",[error description]);
    }
    allNewsCache = matching;
    return matching;
}

- (int)numberOfUnreadMessageInCategory:(NSString*)category
{
    NSArray *match = [self listOfItem];
    int count = 0;
    for(News* news in match)
    {
        //NSLog(@"News:%@",news.title);
        if([news.category.name isEqualToString:category] && ([news.haveread isEqualToNumber:@NO] || news.haveread == nil))
        {
            count++;
        }
    }
    return count;
}

- (int)numberOfFavoritedMessageInCategory:(NSString*)category
{
    NSArray *match = [self listOfItem];
    int count = 0;
    for(News* news in match)
    {
        if([news.category.name isEqualToString:category] && [news.favorated isEqualToNumber:@YES])
        {
            count++;
        }
    }
    return count;
}


-(int)unreadCountInCategory:(NSString*)str
{
    if(!countingSystem)
        [self initCountingSystem];
    for(NSDictionary* dict in countingSystem)
    {
        if([dict[@"text"] isEqualToString:str])
        {
            return [dict[@"unread"] integerValue];
        }
    }
    return 0;
}

-(void)increaseUnreadCountInCategory:(NSString*)str
{
    if([str isEqualToString:@"全部"])
        return;
    if(!countingSystem)
        [self initCountingSystem];
    for(NSMutableDictionary* dict in countingSystem)
    {
        if([dict[@"text"] isEqualToString:str] || [dict[@"text"] isEqualToString:@"全部"] )
        {
            dict[@"unread"] = [NSNumber numberWithInt:[dict[@"unread"] integerValue]+1];
        }
    }
    [NSNotificationCenter postCountChangedNotification];
}
-(void)decreaseUnreadCountInCategory:(NSString*)str
{
    if([str isEqualToString:@"全部"])
        return;
    if(!countingSystem)
        [self initCountingSystem];
    for(NSMutableDictionary* dict in countingSystem)
    {
        if([dict[@"text"] isEqualToString:str] || [dict[@"text"] isEqualToString:@"全部"] )
        {
            int count = [dict[@"unread"] integerValue]-1;
            dict[@"unread"] = [NSNumber numberWithInt:count >= 0 ? count : 0];
        }
    }
    [NSNotificationCenter postCountChangedNotification];
}

-(int)favedCountInCategory:(NSString*)str
{
    if(!countingSystem)
        [self initCountingSystem];
    for(NSDictionary* dict in countingSystem)
    {
        if([dict[@"text"] isEqualToString:str])
        {
            return [dict[@"fav"] integerValue];
        }
    }
    return 0;
}

-(void)increaseFavedCountInCategory:(NSString*)str
{
    if(!countingSystem)
        [self initCountingSystem];
    if([str isEqualToString:@"全部"])
        return;
    for(NSMutableDictionary* dict in countingSystem)
    {
        if([dict[@"text"] isEqualToString:str] || [dict[@"text"] isEqualToString:@"全部"] )
        {
            dict[@"fav"] = [NSNumber numberWithInt:[dict[@"fav"] integerValue]+1];
        }
    }
    [NSNotificationCenter postCountChangedNotification];
}
-(void)decreaseFavedCountInCategory:(NSString*)str
{
    if(!countingSystem)
        [self initCountingSystem];
    if([str isEqualToString:@"全部"])
        return;
    for(NSMutableDictionary* dict in countingSystem)
    {
        if([dict[@"text"] isEqualToString:str] || [dict[@"text"] isEqualToString:@"全部"] )
        {
            int count = [dict[@"fav"] integerValue]-1;
            dict[@"fav"] = [NSNumber numberWithInt:count >= 0 ? count : 0];
        }
    }
    [NSNotificationCenter postCountChangedNotification];
}

-(void)cleanCountingCache
{
    allNewsCache = nil;
    countingSystem = nil;
}
@end
