//
//  NSString+URLRequest.h
//  TongjiXuanke
//
//  Created by Song on 12-11-17.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLRequest)

-(NSURLRequest*) convertToURLRequest;
+(NSURLRequest*) URLRequestWithString:(NSString*)str;

@end
