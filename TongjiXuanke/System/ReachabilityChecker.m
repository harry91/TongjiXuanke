//
//  ReachabilityChecker.m
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "ReachabilityChecker.h"
#import "Reachability.h"

@implementation ReachabilityChecker

ReachabilityChecker *_reachinstance;

+(ReachabilityChecker*)instance
{
    if(!_reachinstance)
    {
        _reachinstance = [[ReachabilityChecker alloc] init];
    }
    return _reachinstance;
}

-(id)init
{
    if(self = [super init])
    {
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
        // method "reachabilityChanged" will be called.
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
        
        //Change the host name here to change the server your monitoring
        hostReach = [Reachability reachabilityWithHostName: @"xuanke.tonji.edu.cn"];
        [hostReach startNotifier];
        [self update: hostReach];
        
        internetReach = [Reachability reachabilityForInternetConnection];
        [internetReach startNotifier];
        [self update: hostReach];
        
        wifiReach = [Reachability reachabilityForLocalWiFi];
        [wifiReach startNotifier];
        [self update: hostReach];
        
    }
    return self;
}

-(BOOL)hasInternetAccess
{
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
        case ReachableViaWiFi:
        {
            return YES;
        }
    }
}

-(BOOL)usingWIFI
{
    //return NO;
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
            return YES;
        }
    }
}

-(void)update: (Reachability*) curReach
{
    
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self update: curReach];
}

@end
