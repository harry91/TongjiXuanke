//
//  NewsLoaderProtocal.h
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewsLoaderProtocal <NSObject>

-(void)finishedLoading:(NSString*)category;

-(void)errorLoading:(NSError*)error;

@end
