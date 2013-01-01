//
//  FakeNews.h
//  TongjiXuanke
//
//  Created by Song on 12-11-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeNews : NSObject

@property (nonatomic, retain) NSString * briefcontent;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * favorated;
@property (nonatomic, retain) NSNumber * haveread;

@end
