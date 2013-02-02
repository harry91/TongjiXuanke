//
//  AppDelegate.m
//  TongjiXuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import "APNSManager.h"
#import "Brain.h"
#import "Crittercism.h"
#import "MyDataStorage.h"
//#import <ShareSDK/ShareSDK.h>

@implementation AppDelegate


- (void)customizeAppearance
{

//    UIImage *segmentSelected = [[UIImage imageNamed:@"segcontrol_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
//    UIImage *segmentUnselected = [[UIImage imageNamed:@"segcontrol_uns.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
//    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-uns.png"];
//    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_uns-sel.png"];
//    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
//    
//    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//    
//    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
//    CGRect rect = CGRectMake(0, 0, 1, 1);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    [[UISegmentedControl appearance] setBackgroundImage:transparentImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setDividerImage:transparentImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:75/255.0 green:165/255.0 blue:245/255.0 alpha:0.0]];
    
//    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbarBG.png"]];
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"selectedIndicator.png"]];
//    
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIColor colorWithWhite:0.5 alpha:1], UITextAttributeTextColor,
//                                                       [UIColor blackColor], UITextAttributeTextShadowColor, nil]
//                                             forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                       [UIColor colorWithWhite:0.85 alpha:1], UITextAttributeTextColor,
//                                                       [UIColor blackColor], UITextAttributeTextShadowColor, nil]
//                                             forState:UIControlStateSelected];
//    
}

- (void)initUserDefault
{
    [NSUserDefaults initialize];
    
    NSDictionary *userDefaultsDefaults = @{@"selectedCategoryArray" : @[@0,@1]};
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crittercism enableWithAppID: @"50e1d58af716967858000007"];

    //[ShareSDK registerApp:@"50fcda8e"];
    
    [self initUserDefault];
    
    [self customizeAppearance];
    
    [Parse setApplicationId:@"fHKruOIrAtqIDOOOWHMUrvhk0dOwjplFOCjdL6CL"
                  clientKey:@"ektKKdJ3PznuAyqBicBc6JuLA5Jj0fF3Nlzv1hps"];
      
    //[[Brain instance] refresh];
    [[Brain instance] performSelector:@selector(refresh) withObject:nil afterDelay:0.5];
    
    return YES;
}


/*
 * ------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE
 * ------------------------------------------------------------------------------------------
 */

/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */

- (void)registerDevice:(NSData*)devToken
{
    [APNSManager RegisterDevice:devToken];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
#if !TARGET_IPHONE_SIMULATOR
    [self performSelectorInBackground:@selector(registerDevice:) withObject:devToken];
#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"Error in registration. Error: %@", error);
    
#endif
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
#if !TARGET_IPHONE_SIMULATOR
    [[Brain instance] resetTimer];
    [[Brain instance] refresh];

	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
    
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
    
    UIAlertView *alertWindow =   [[UIAlertView alloc] initWithTitle: @"新通知" message: alert delegate: self cancelButtonTitle: @"知道了" otherButtonTitles: nil];
    [alertWindow show];
#endif
}

#pragma mark Share Callback
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//    return [ShareSDK handleOpenURL:url wxDelegate:self];
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    return  [ShareSDK handleOpenURL:url wxDelegate:self];
//}



/*
 * ------------------------------------------------------------------------------------------
 *  END APNS CODE
 * ------------------------------------------------------------------------------------------
 */


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[Brain instance] resetTimer];
    [[Brain instance] refresh];
    [APNSManager cleanBadge];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
