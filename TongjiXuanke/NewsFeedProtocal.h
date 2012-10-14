//
//  NewsFeedProtocal.h
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewsFeedProtocal <NSObject>

-(int)totalNewsCount;

-(NSString*)titleForNewsIndex:(int)index;
-(NSString*)contentForNewsIndex:(int)index;
-(NSString*)idForNewsIndex:(int)index;
-(NSString*)timeForNewsIndex:(int)index;
-(NSString*)catagoryForNewsIndex:(int)index;

@end
