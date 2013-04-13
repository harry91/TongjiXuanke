//
//  DataOperator.m
//  TongjiXuanke
//
//  Created by Song on 12-11-11.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DataOperator.h"
#import "SettingModal.h"
#import "NSNotificationCenter+Xuanke.h"
#import <IAThreadSafeCoreData/IAThreadSafeManagedObject.h>
#import <IAThreadSafeCoreData/IAThreadSafeContext.h>

@implementation DataOperator

DataOperator* _dataOperatorInstance = nil;

+(DataOperator*)instance
{
    if(!_dataOperatorInstance)
    {
        _dataOperatorInstance = [[DataOperator alloc] init];
    }
    return _dataOperatorInstance;
}

- (id)init
{
    if(self = [super init])
    {
       
    }
    return self;
}

-(Category*)distinctCategory:(NSString*)categoryTitle inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"Category" inManagedObjectContext:context]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(name == %@)", categoryTitle]];
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!matching)
    {
        NSLog(@"Error: %@",[error description]);
    }
    if(matching.count > 0)
    {
        return [matching lastObject];
    }
    
    Category *category = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Category"
                          inManagedObjectContext:context];
    category.name = categoryTitle;
    [context save:nil];
    return category;
}

- (void)myManagedObjectContextDidSaveNotificationHander:(NSNotification *)notification
{
    // since we are in a background thread, we should merge our changes on the main
    // thread to get updates in `NSFetchedResultsController`, etc.
    [[MyDataStorage instance].managedObjectContext  performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
}

-(void)multiThreadDistinctSave:(FakeNews*)newsToInsert inCategory:(NSString*)categoryTitle
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
    
        @synchronized(self) {
            NSManagedObjectContext *context = [[IAThreadSafeContext alloc] init];
            [context setPersistentStoreCoordinator:[MyDataStorage instance].persistentStoreCoordinator];
            
            // Create the fetch request
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:
             [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
            [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(url == %@)", newsToInsert.url]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myManagedObjectContextDidSaveNotificationHander:) name:NSManagedObjectContextDidSaveNotification object:context];
            
            NSError *error;
            NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
            
            if(!matching)
            {
                NSLog(@"Error: %@",[error description]);
            }
            if(matching.count > 0)
            {
                BOOL found = NO;
                News *item;
                for(item in matching)
                {
                    if([item.category.name isEqualToString:categoryTitle])
                    {
                        found = YES;
                        break;
                    }
                }
                if(found)
                {
                    [[SettingModal instance] increaseUnreadCountInCategory:categoryTitle];
                    if(newsToInsert.content && ![item.title isEqualToString:@"snow"])
                    {
                        if(![newsToInsert.content isEqualToString:item.content])//update content;
                        {
                            item.content = newsToInsert.content;
                            item.briefcontent = newsToInsert.briefcontent;
                            item.date = newsToInsert.date;
                            item.title = newsToInsert.title;
                            item.favorated = NO;
                            item.haveread = NO;
                            [context save:&error];
                            [self checkForPersonalInfo:item];
                        }
                    }
                    return;
                }
            }
            [[SettingModal instance] increaseUnreadCountInCategory:categoryTitle];

            News *news = [NSEntityDescription
                          insertNewObjectForEntityForName:@"News"
                          inManagedObjectContext:context];
            
            news.category = [self distinctCategory:categoryTitle inContext:context];
            news.title = newsToInsert.title;
            news.briefcontent = newsToInsert.briefcontent;
            news.content = newsToInsert.content;
            news.date = newsToInsert.date;
            news.favorated = newsToInsert.favorated;
            news.haveread = newsToInsert.haveread;
            news.url = newsToInsert.url;
            
            error = nil;
            if (context != nil) {
                if ([context hasChanges] && ![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
            [self checkForPersonalInfo:news];
        }
        
    });
}


-(void)distinctSave:(FakeNews*)newsToInsert inCategory:(NSString*)categoryTitle
{
    //[self multiThreadDistinctSave:newsToInsert inCategory:categoryTitle];
    //return;
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
    {
        NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
        
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:
         [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
        [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(url == %@)", newsToInsert.url]];
        
        
        // make sure the results are sorted as well
        
        NSError *error;
        NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
        
        if(!matching)
        {
            NSLog(@"Error: %@",[error description]);
        }
        if(matching.count > 0)
        {
            BOOL found = NO;
            News *item;
            for(item in matching)
            {
                if([item.category.name isEqualToString:categoryTitle])
                {
                    found = YES;
                    break;
                }
            }
            if(found)
            {
                if(newsToInsert.content && ![item.title isEqualToString:@"snow"])
                {
                    if(![newsToInsert.content isEqualToString:item.content])//update content;
                    {
                        item.content = newsToInsert.content;
                        item.briefcontent = newsToInsert.briefcontent;
                        item.date = newsToInsert.date;
                        item.title = newsToInsert.title;
                        item.favorated = NO;
                        item.haveread = NO;
                        [[MyDataStorage instance] saveContext];
                        [self checkForPersonalInfo:item];
                        
                    }
                }
                return;
            }
        }
        
        News *news = [NSEntityDescription
                      insertNewObjectForEntityForName:@"News"
                      inManagedObjectContext:context];
        
        
        news.category = [self distinctCategory:categoryTitle inContext:context];
        news.title = newsToInsert.title;
        news.briefcontent = newsToInsert.briefcontent;
        news.content = newsToInsert.content;
        news.date = newsToInsert.date;
        news.favorated = newsToInsert.favorated;
        news.haveread = newsToInsert.haveread;
        news.url = newsToInsert.url;
        
        [[MyDataStorage instance] saveContext];
        
        [self checkForPersonalInfo:news];
    }
    //);
}


-(void)checkForPersonalInfo:(News*)news
{
    BOOL result = NO;
    if([news.content rangeOfString:[SettingModal instance].studentID].location != NSNotFound)
    {
        if(news.content)
        {
            result = result | YES;
        }
    }
    if([SettingModal instance].hasStudentProfileSet)
    {
        //NSLog(@"name: %@",[SettingModal instance].studentName);
        if([news.content rangeOfString:[SettingModal instance].studentName].location != NSNotFound)
        {
            if(news.content)
            {
                result = result | YES;
            }
        }
    }
    if(result)
    {
        [NSNotificationCenter postFoundPersenalInfoInNewsNotification:news];
    }
}



-(void)cleanUpExpireNews
{
    if([[SettingModal instance] autoCleanInterval] == 0)
        return;
    NSDate *now = [NSDate date];
    
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    for(News* item in matching)
    {
        if(![item.favorated isEqualToNumber:[NSNumber numberWithBool:YES]])
        {
            double deltaSeconds = fabs([item.date timeIntervalSinceDate:now]);
            double deltaMinutes = deltaSeconds / 60.0f;
            int monthAgo = (int)floor(deltaMinutes/(60 * 24 * 30));
            if(monthAgo >= [[SettingModal instance] autoCleanInterval])
            {
                NSLog(@"Cleaned item: %@",item.title);
                [context deleteObject:item];
            }
        }
    }
    [[MyDataStorage instance] saveContext];
}

- (NSString*)allFilterClause
{
    NSMutableString *str = [@"" mutableCopy];
    NSMutableArray *arr = [@[] mutableCopy];
    for(int i = 0; i < [[SettingModal instance] numberOfCategory]; i++)
    {
        if([[SettingModal instance] hasSubscribleCategoryAtIndex:i])
        {
            NSString * s = [NSString stringWithFormat:@" category.name == \"%@\" ",[[SettingModal instance] nameForCategoryAtIndex:i]];
            
            [arr addObject:s];
        }
    }
    for(int i = 0; i < arr.count; i++)
    {
        [str appendString:arr[i]];
        if(i+1 != arr.count)
            [str appendString:@"OR"];
    }
    return str;
}

@end
