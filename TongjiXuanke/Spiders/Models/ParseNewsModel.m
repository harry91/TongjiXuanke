//
//  ParseNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 13-1-13.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "ParseNewsModel.h"
#import "UIApplication+Toast.h"
#import "FakeNews.h"
#import "DataOperator.h"
#import "NSString+URLRequest.h"
#import "NSString+HTML.h"
#import <Parse/Parse.h>
#import "NSNotificationCenter+Xuanke.h"

@implementation ParseNewsModel
-(id)init
{
    if(self = [super init])
    {
        isgetting = NO;
        
        urlToRetireve = [@[] mutableCopy];

        serverCategory = @"";
    }
    return self;
}


-(void)save
{
    for(int i = 0; i <[self totalNewsCount]; i++)
    {
        if([self shouldSaveThisNewsWithThisDate:[self timeForNewsIndex:i]])
        {
            FakeNews *news = [[FakeNews alloc] init];
            news.title = [self titleForNewsIndex:i];
            
            news.briefcontent = nil;
            
            news.content = nil;
            news.date = [self timeForNewsIndex:i];
            news.favorated = NO;
            news.haveread = NO;
            news.url = [self idForNewsIndex:i];
            [[DataOperator instance] distinctSave:news inCategory:[self catagoryForNews]];
        }
    }
    [NSNotificationCenter postCategoryChangedNotification];
}


- (void)startDownloadList
{
    dict = [@[] mutableCopy];
    
    PFQuery *query = [PFQuery queryWithClassName:@"RSS"];
    [query whereKey:@"category" equalTo:serverCategory];
    query.limit = 50;
    [query orderByDescending:@"newsTime"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *list, NSError *error) {
        for (PFObject *aNews in list) {
            NSString *date = [aNews objectForKey:@"newsTime"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *myDate = [df dateFromString: date];
            
            NSString* newsURL = [aNews objectForKey:@"url"];
            NSString* title = [aNews objectForKey:@"title"];
            
            
            NSDictionary *item = @{@"url":newsURL, @"title":title, @"date": myDate};
            [dict addObject:item];
            
        }
        [self performSelectorOnMainThread:@selector(finishDownloadList) withObject:nil waitUntilDone:NO];
    }];
}

- (void)finishDownloadList
{
    [self save];
    [self.delegate finishedLoadingInCategory:self.categoryIndex];
}

#pragma mark detail getting
-(void)retreivingTherad
{
    NSLog(@"URL TO GO %@",urlToRetireve);
    if(urlToRetireve.count <= 0)
    {
        isgetting = NO;
        return;
    }
    isgetting = YES;
    curl = urlToRetireve[0];
    [urlToRetireve removeObjectAtIndex:0];
    [self retreiveDetailForUrlLocal:curl];
}

-(BOOL)retreiveDetailForUrl:(NSString*)url
{
    [urlToRetireve insertObject:url atIndex:0];
    if(!isgetting)
    {
        [self retreivingTherad];
    }
    return YES;///TODO bug.....
}


-(NSString*)fullTextForPFObject:(PFObject*)item
{
    NSString* str = [item objectForKey:@"content"];
    NSArray *listItems = [str componentsSeparatedByString:@","];
    NSMutableString *content = [@"" mutableCopy];
    for(NSString* textID in listItems)
    {
        if ([textID isEqualToString:@""]) {
            continue;
        }
        PFQuery *query = [PFQuery queryWithClassName:@"TextDB"];
        PFObject *textObj = [query getObjectWithId:textID];
        NSString *text = [textObj objectForKey:@"text"];
        [content appendString:text];
    }
    return content;
}

-(void)finishRetrievingDataForUrl:(NSString*)url
{
    if([parseTextContent isEqualToString:@""])
        return;
    
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(url == %@)", url]];
    
    // make sure the results are sorted as well
    
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!matching)
    {
        NSLog(@"Error: %@",[error description]);
    }
    News *news;
    if(matching.count > 0)
    {
        for(News *item in matching)
        {
            if([item.category.name isEqualToString:[self catagoryForNews]])
            {
                news = item;
                break;
            }
        }
    }
    
    news.content = parseTextContent;
    news.briefcontent = [parseTextContent stringByConvertingHTMLToPlainText];
    
    
    [self retreivingTherad];
}

-(BOOL)retreiveDetailForUrlLocal:(NSString*)url
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFQuery *query = [PFQuery queryWithClassName:@"RSS"];
        [query whereKey:@"category" equalTo:serverCategory];
        [query whereKey:@"url" equalTo:url];
        query.limit = 1;
        NSArray* itemList = [query findObjects];
        if(itemList.count == 0)
            parseTextContent = @"";
        parseTextContent = [self fullTextForPFObject:[itemList lastObject]];
        [[UIApplication sharedApplication] hideNetworkIndicator];
        
        [self performSelectorOnMainThread:@selector(finishRetrievingDataForUrl:) withObject:curl waitUntilDone:NO];
    });
    
    return YES;
}


-(void)retreiveDetails
{
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //[fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(category == %@)", [self catagoryForNews]]];
    NSError *error;
    NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
    
    for(News* item in matching)
    {
        if(item.content == nil && [item.category.name isEqualToString:[self catagoryForNews]])
        {
            [self addURLtoRetirve:item.url];
        }
    }
}

-(void)addURLtoRetirve:(NSString*)url
{
    [urlToRetireve addObject:url];
    if(!isgetting)
    {
        [self retreivingTherad];
    }
}


#pragma mark News Feed Protocal
-(void)realStart
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    [self performSelectorInBackground:@selector(startDownloadList) withObject:nil];
}

-(int)totalNewsCount
{
    return dict.count;
}

-(NSString*)titleForNewsIndex:(int)index
{
    return dict[index][@"title"];
}

-(NSString*)contentForNewsIndex:(int)index
{
    return nil;
}

-(NSString*)idForNewsIndex:(int)index
{
    
    return dict[index][@"url"];
}

-(NSDate*)timeForNewsIndex:(int)index
{
    return dict[index][@"date"];
}

@end
