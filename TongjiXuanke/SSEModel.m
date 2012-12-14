//
//  SSEModel.m
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SSEModel.h"
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
#import "NSString+URLRequest.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1


@implementation SSEModel

-(id)init
{
    if(self = [super init])
    {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        
        parsedItems = [[NSMutableArray alloc] init];
        
        NSURL *feedURL = [NSURL URLWithString:@"http://sse.tongji.edu.cn/SSEMainRSS.aspx"];
        feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
        feedParser.delegate = self;
        feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
        feedParser.connectionType = ConnectionTypeAsynchronously;
        
        isgetting = NO;
        
        urlToRetireve = [@[] mutableCopy];
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
}



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

- (void)finishRetreiving:(NSString *)aUrl
{
    NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(url == %@)", aUrl]];
    
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
    
    NSRange start = [tempContent rangeOfString:@"<div id=\"content\" class=\"content\">"];
    
    tempContent = [tempContent substringFromIndex:start.location + start.length];
    
    NSRange end = [tempContent rangeOfString:@"<!-- InstanceEndEditable -->"];
    
    tempContent = [tempContent substringToIndex:end.location];
    
    news.content = tempContent;
    
    
    NSString *briefContent = [news.content  stringByConvertingHTMLToPlainText];
    
    briefContent =  [briefContent stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    briefContent =  [briefContent stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    //briefContent =  [briefContent stringByReplacingOccurrencesOfString: news.title withString:@""];
    briefContent =  [briefContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    news.briefcontent = briefContent;
    
    //NSLog(@"URL:%@ Content:%@",url,tempBriefContent);
    [[MyDataStorage instance] saveContext];
    [self performSelector:@selector(retreivingTherad) withObject:nil afterDelay:1];
    
}


//- (void)loadWebPageWithString:(NSString*)urlString
//{
//    NSURL *url =[NSURL URLWithString:urlString];
//    NSURLRequest *request =[NSURLRequest requestWithURL:url];
//    [_webView loadRequest:request];
//}

-(BOOL)retreiveDetailForUrlLocal:(NSString*)url
{
    [[UIApplication sharedApplication] showNetworkIndicator];
    [_webView loadRequest:[url convertToURLRequest]];
    
    return YES;//TODO bug
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


#pragma mark web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] hideNetworkIndicator];
    
    tempContent = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    tempBriefContent = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText;"];
    
    NSString *currentURL = _webView.request.URL.absoluteString;
    
    [self finishRetreiving:currentURL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

#pragma mark News Feed Protocal
-(void)realStart
{
    [[UIApplication sharedApplication] showNetworkIndicator];
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
        NSLog(@"SSE RSS Failed");
        [self.delegate errorLoading:error inCategory:self.categoryIndex];
    } else {
        NSLog(@"SSE RSS partly Failed"); 
        // Failed but some items parsed, so show and inform of error
        [self save];
        [self.delegate finishedLoadingInCategory:self.categoryIndex];
    }
    [[UIApplication sharedApplication] hideNetworkIndicator];
}



@end
