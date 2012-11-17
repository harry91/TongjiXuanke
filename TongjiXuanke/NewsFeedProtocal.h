//
//  NewsFeedProtocal.h
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewsFeedProtocal <NSObject>


-(void)start;
-(void)retreiveDetails;
-(BOOL)retreiveDetailForUrl:(NSString*)url;

-(int)totalNewsCount;

-(NSString*)titleForNewsIndex:(int)index;
-(NSString*)contentForNewsIndex:(int)index;
-(NSString*)idForNewsIndex:(int)index;
-(NSDate*)timeForNewsIndex:(int)index;
-(NSString*)catagoryForNews;
-(NSURL*)baseURL;


@end
