//
//  LoginViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ReachabilityChecker.h"
#import "LogInModal.h"

@interface LoginViewController : UIViewController<NewsLoaderProtocal>
{
    MBProgressHUD *HUD;
    LogInModal *loginModel;
    
}
@property (strong, nonatomic) PPRevealSideViewController *revealSideViewController;


@property (weak, nonatomic) IBOutlet UITextField *studentNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inputBG;

@end
