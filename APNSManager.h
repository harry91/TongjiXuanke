//
//  APNSManager.h
//  TongjiXuanke
//
//  Created by Song on 12-11-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APNSManager : NSObject

+(void)requestAPNS;
+(void)cleanBadge;
+(BOOL)RegisterDevice:(NSData*)devToken;
+(BOOL)cleanAllSubscrible;
+(BOOL)subscribleCategory:(int)value;

+(BOOL)reSubscrible;

@end
