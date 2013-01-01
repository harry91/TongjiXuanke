//
//  NSString+URLRequest.m
//  TongjiXuanke
//
//  Created by Song on 12-11-17.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NSString+URLRequest.h"

@implementation NSString (URLRequest)

-(NSURLRequest*) convertToURLRequest
{
    return [NSString URLRequestWithString:self];
}

+(NSURLRequest*) URLRequestWithString:(NSString*)str
{
    NSURL *url =[NSURL URLWithString:str];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    return request;
}

@end
