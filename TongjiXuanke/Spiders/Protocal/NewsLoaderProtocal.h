//
//  NewsLoaderProtocal.h
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewsLoaderProtocal <NSObject>

-(void)finishedLoadingInCategory:(int)categoryIndex;

-(void)errorLoading:(NSError*)error inCategory:(int)categoryIndex;

@end
