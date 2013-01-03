//
//  DataOperator.h
//  TongjiXuanke
//
//  Created by Song on 12-11-11.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyDataStorage.h"
#import "News.h"
#import "Category.h"
#import "FakeNews.h"

@interface DataOperator : NSObject

+(DataOperator*)instance;

-(Category*)distinctCategory:(NSString*)categoryTitle;

-(void)distinctSave:(FakeNews*)newsToInsert inCategory:(NSString*)categoryTitle;

-(void)cleanUpExpireNews;

- (NSString*)allFilterClause;

@end
