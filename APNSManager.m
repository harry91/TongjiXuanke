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

+ (void)parseRegister:(NSString *)deviceUuid deviceModel:(NSString *)deviceModel deviceSystemVersion:(NSString *)deviceSystemVersion deviceName:(NSString *)deviceName
{
    PFInstallation *myInstallation = [PFInstallation currentInstallation];
    
    [myInstallation setObject:deviceUuid forKey:@"itisme"];
    [myInstallation setObject:deviceModel forKey:@"model"];
    [myInstallation setObject:deviceSystemVersion forKey:@"systemversion"];
    [myInstallation setObject:deviceName forKey:@"devicecalled"];
    
    if([[SettingModal instance] hasStudentProfileSet])
    {
        [myInstallation setObject:[SettingModal instance].studentName  forKey:@"name"];
        [myInstallation setObject:[SettingModal instance].studentDepartment  forKey:@"department"];
        [myInstallation setObject:[SettingModal instance].studentMajor  forKey:@"major"];
    }
    [myInstallation setObject:[SettingModal instance].studentID  forKey:@"studentID"];
    
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];;
    
    [myInstallation setObject:pwd  forKey:@"AES"];
    
    // Save or Create installation object
    [myInstallation saveEventually];
}

+(BOOL)RegisterDevice:(NSData*)devToken
{
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    appName = @"pushdemo";
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";
    
	// Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
	// one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
	// single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
	// true if those two notifications are on.  This is why the code is written this way
	if(rntypes == UIRemoteNotificationTypeBadge){
		pushBadge = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeAlert){
		pushAlert = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeSound){
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
    pushBadge = @"enabled";
    pushAlert = @"enabled";
    pushSound = @"enabled";
    
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
    
    
    [self parseRegister:deviceUuid deviceModel:deviceModel deviceSystemVersion:deviceSystemVersion deviceName:deviceName];
    
    
    
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
