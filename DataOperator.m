//
//  DataOperator.m
//  TongjiXuanke
//
//  Created by Song on 12-11-11.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "DataOperator.h"
#import "SettingModal.h"

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


-(Category*)distinctCategory:(NSString*)categoryTitle
{
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
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
    [[MyDataStorage instance] saveContext];
    return category;
}


-(void)distinctSave:(FakeNews*)newsToInsert inCategory:(NSString*)categoryTitle
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
        for(News *item in matching)
        {
            if([item.category.name isEqualToString:categoryTitle])
            {
                found = YES;
                break;
            }
        }
        if(found)
            return;
    }
    
    News *news = [NSEntityDescription
                  insertNewObjectForEntityForName:@"News"
                  inManagedObjectContext:context];
    
    
    news.category = [self distinctCategory:categoryTitle];
    news.title = newsToInsert.title;
    news.briefcontent = newsToInsert.briefcontent;
    news.content = newsToInsert.content;
    news.date = newsToInsert.date;
    news.favorated = newsToInsert.favorated;
    news.haveread = newsToInsert.haveread;
    news.url = newsToInsert.url;

    [[MyDataStorage instance] saveContext];
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


@end
