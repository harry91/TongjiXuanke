//
//  APNSManager.m
//  TongjiXuanke
//
//  Created by Song on 12-11-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "APNSManager.h"
#import "UIDevice+IdentifierAddition.h"
#import "SettingModal.h"
#import <Parse/Parse.h>

@implementation APNSManager

NSString *deviceToken;

// Build URL String for Registration
// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
// !!! SAMPLE: "secure.awesomeapp.com"
NSString *host = @"www.sbhhbs.com";


+(BOOL)RegisterDevice:(NSData*)devToken
{
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    appName = @"pushdemo";
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = @"enabled";
	NSString *pushAlert = @"enabled";
	NSString *pushSound = @"enabled";
    
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [dev uniqueGlobalDeviceIdentifier];
    NSString *deviceName = dev.name;
	NSString *deviceModel = [dev platform];
	NSString *deviceSystemVersion = dev.systemVersion;
    
	// Prepare the Device Token for Registration (remove spaces and < >)
	deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
        
    
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
	// !!! ( MUST START WITH / AND END WITH ? ).
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [@"/APNS/apns.php?"stringByAppendingString:@"task=register"];
    
	urlString = [urlString stringByAppendingString:@"&appname="];
	urlString = [urlString stringByAppendingString:appName];
	urlString = [urlString stringByAppendingString:@"&appversion="];
	urlString = [urlString stringByAppendingString:appVersion];
	urlString = [urlString stringByAppendingString:@"&deviceuid="];
	urlString = [urlString stringByAppendingString:deviceUuid];
	urlString = [urlString stringByAppendingString:@"&devicetoken="];
	urlString = [urlString stringByAppendingString:deviceToken];
	urlString = [urlString stringByAppendingString:@"&devicename="];
	urlString = [urlString stringByAppendingString:deviceName];
	urlString = [urlString stringByAppendingString:@"&devicemodel="];
	urlString = [urlString stringByAppendingString:deviceModel];
	urlString = [urlString stringByAppendingString:@"&deviceversion="];
	urlString = [urlString stringByAppendingString:deviceSystemVersion];
	urlString = [urlString stringByAppendingString:@"&pushbadge="];
	urlString = [urlString stringByAppendingString:pushBadge];
	urlString = [urlString stringByAppendingString:@"&pushalert="];
	urlString = [urlString stringByAppendingString:pushAlert];
	urlString = [urlString stringByAppendingString:@"&pushsound="];
	urlString = [urlString stringByAppendingString:pushSound];
    
    
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSLog(@"Register URL: %@", url);
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
	NSLog(@"Register Return String: %@", aStr);
    if(![aStr isEqualToString:@"success"])
        return NO;
    return YES;
}

+(BOOL)cleanAllSubscrible
{
    if(!deviceToken)
        return NO;

    NSString *urlString = [@"/APNS/dropNotice.php?"stringByAppendingString:@"token="];
    urlString = [urlString stringByAppendingString:deviceToken];
    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSLog(@"Drop URL: %@", url);
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
	NSLog(@"Drop Return String: %@", aStr);

    return YES;
}

+(BOOL)desubscribleCategory:(int)value
{
    if(!deviceToken)
        return NO;
    
    NSString *urlString = [@"/APNS/delNotice.php?"stringByAppendingString:@"token="];
    urlString = [urlString stringByAppendingString:deviceToken];
    urlString = [urlString stringByAppendingString:@"&notice="];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"%d",value]];
    
    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSLog(@"Desubscrible URL: %@", url);
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
	NSLog(@"Desubscrible Return String: %@", aStr);
    
    return YES;
}

+(BOOL)subscribleCategory:(int)value
{
    if(!deviceToken)
        return NO;
    
    NSString *urlString = [@"/APNS/regNotice.php?"stringByAppendingString:@"token="];
    urlString = [urlString stringByAppendingString:deviceToken];
    urlString = [urlString stringByAppendingString:@"&notice="];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"%d",value]];
    
    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSLog(@"Subscrible URL: %@", url);
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
	NSLog(@"Subscrible Return String: %@", aStr);

    return YES;
}

+(void)requestAPNS
{
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

+(void)cleanBadge
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

+(BOOL)reSubscrible
{
    if(!deviceToken)
        return NO;
    [APNSManager cleanAllSubscrible];
    
    SettingModal *instance = [SettingModal instance];
    
    for(int i = 0; i < [instance numberOfCategory]; i++)
    {
        if([instance hasSubscribleCategoryAtIndex:i])
        {
            [APNSManager subscribleCategory:[instance serverIDForCategoryAtIndex:i]];
        }
    }
    return YES;
}


@end
