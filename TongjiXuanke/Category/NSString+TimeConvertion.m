//
//  NSString+TimeConvertion.m
//  TongjiXuanke
//
//  Created by Song on 12-10-15.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NSString+TimeConvertion.h"

@implementation NSString (TimeConvertion)

+(NSString*)stringByConvertingTimeToAgoFormatFromDate:(NSDate*)date;
{
    NSDate *myDate = date;
    
    
    // Your dates:
    NSDate * today = [NSDate date];
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400]; //86400 is the seconds in a day
    NSDate * refDate = myDate; // your reference date
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:tz];

    NSString * todayString = [dateFormatter stringFromDate:today];
    NSString * yesterdayString = [dateFormatter stringFromDate:yesterday];
    NSString * refDateString = [dateFormatter stringFromDate:refDate];
    NSString* result;
    
    if ([refDateString isEqualToString:todayString])
    {
        result =  @"今天";
    } else if ([refDateString isEqualToString:yesterdayString])
    {
        result =  @"昨天";
    } else
    {
        result =  refDateString;
    }
    
    return result;
}


@end
