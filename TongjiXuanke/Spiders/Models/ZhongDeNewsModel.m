//
//  ZhongDeNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 13-1-7.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "ZhongDeNewsModel.h"
#import "News.h"
#import "Category.h"
#import "MyDataStorage.h"
#import "SettingModal.h"
#import "ReachabilityChecker.h"
#import "MWFeedItem.h"
#import "NSString+HTML.h"
#import "DataOperator.h"
#import "SettingModal.h"
#import "UIApplication+Toast.h"
#import "NSNotificationCenter+Xuanke.h"


@implementation ZhongDeNewsModel


-(id)init
{
    if(self = [super init])
    {
        parsedItems = [[NSMutableArray alloc] init];
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
            
            MWFeedItem *item = parsedItems[i];
            if (item) {
                // Process
                NSString *itemTitle = item.summary;
                news.briefcontent = [itemTitle stringByConvertingHTMLToPlainText];
                news.content = item.summary;
            }
            
            news.date = [self timeForNewsIndex:i];
            news.favorated = NO;
            news.haveread = NO;
            news.url = [self idForNewsIndex:i];
            [[DataOperator instance] distinctSave:news inCategory:[self catagoryForNews]];
        }
    }
    [NSNotificationCenter postCategoryChangedNotification];
}

-(void)start
{
    if(![feedParser isParsing])
    {
        [self realStart];
    }
}

-(BOOL)retreiveDetailForUrl:(NSString*)url
{
    return YES;
}


-(void)retreiveDetails
{
    
}

#pragma mark News Feed Protocal
-(void)realStart
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    NSString *url = @"http://cdhawjw.blog.163.com/rss";
    
    NSURL *feedURL = [NSURL URLWithString:url];
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
}


-(int)totalNewsCount
{
    return parsedItems.count;
}

-(NSString*)titleForNewsIndex:(int)index
{
    MWFeedItem *item = parsedItems[index];
	if (item) {
		// Process
		NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        return itemTitle;
    }
    return nil;
}

-(NSString*)contentForNewsIndex:(int)index
{
    return nil;
}

-(NSString*)idForNewsIndex:(int)index
{
    MWFeedItem *item = parsedItems[index];
	if (item) {
		// Process
		NSString *itemID = item.link;
        return itemID;
    }
    return nil;
}

-(NSDate*)timeForNewsIndex:(int)index
{
    MWFeedItem *item = parsedItems[index];
	if (item) {
		// Process
		NSDate *itemDate = item.date;
        return itemDate;
    }
    return nil;
}

-(NSString*)safariLink:(News*)aNews
{
    return aNews.url;
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	NSLog(@"Parsed Feed Info: “%@”", info.title);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self save];
    [self.delegate finishedLoadingInCategory:self.categoryIndex];
    lastUpdateEnd = [NSDate date];
    [[UIApplication sharedApplication] hideNetworkIndicator];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        NSLog(@"RSS:%@ Failed",parser.url);
        [self.delegate errorLoading:error inCategory:self.categoryIndex];
    } else {
        NSLog(@"RSS:%@ partly Failed",parser.url);
        // Failed but some items parsed, so show and inform of error
        [self save];
        [self.delegate finishedLoadingInCategory:self.categoryIndex];
    }
    [[UIApplication sharedApplication] hideNetworkIndicator];
}


@end
