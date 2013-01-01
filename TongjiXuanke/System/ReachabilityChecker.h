//
//  ReachabilityChecker.h
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;
@interface ReachabilityChecker : NSObject
{
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
}

+(ReachabilityChecker*)instance;
-(BOOL)hasInternetAccess;
-(BOOL)usingWIFI;
@end
