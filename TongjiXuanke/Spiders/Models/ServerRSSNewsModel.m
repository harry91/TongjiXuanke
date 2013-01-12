//
//  ServerRSSNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 12-12-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "ServerRSSNewsModel.h"
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

@implementation ServerRSSNewsModel


-(id)init
{
    if(self = [super init])
    {
        categoryOnServer = @"test";
    }
    return self;
}

-(void)start
{
    if(![feedParser isParsing])
    {
        [self realStart];
    }
}

#pragma mark News Feed Protocal

-(NSString*)rssURL
{
    return [@"http://sbhhbs.com/tjtzzzd/rss/index.php?feed=rss&c=" stringByAppendingString:categoryOnServer];
}

-(void)realStart
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    NSString *url = [self rssURL];
    
    NSURL *feedURL = [NSURL URLWithString:url];
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
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
	if (item)
    {
        if([self shouldSaveThisNewsWithThisDate:item.date])
        {
            FakeNews *news = [[FakeNews alloc] init];
            news.title = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
            
            NSString *itemSummary = item.summary;
            itemSummary =  [itemSummary stringByReplacingOccurrencesOfString: @"\r" withString:@""];
            itemSummary =  [itemSummary stringByReplacingOccurrencesOfString: @"\n" withString:@""];
            itemSummary =  [itemSummary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            news.briefcontent = [itemSummary stringByConvertingHTMLToPlainText];
            
            news.content = item.summary;
            
            news.date = item.date;
            news.favorated = NO;
            news.haveread = NO;
            news.url = item.link;
            [[DataOperator instance] distinctSave:news inCategory:[self catagoryForNews]];
        }
    }
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self.delegate finishedLoadingInCategory:self.categoryIndex];
    lastUpdateEnd = [NSDate date];
    [[UIApplication sharedApplication] hideNetworkIndicator];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
    [[UIApplication sharedApplication] hideNetworkIndicator];
}



@end
