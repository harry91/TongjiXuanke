//
//  LoginViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "LoginViewController.h"
#import "NSString+EncryptAndDecrypt.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)trans
{
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newsView"];
    
    self.revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:vc];
    [self.revealSideViewController setPanInteractionsWhenClosed:PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar];
    [self.revealSideViewController setDirectionsToShowBounce:PPRevealSideDirectionLeft];
    
    UIViewController* leftBar = [self.storyboard instantiateViewControllerWithIdentifier:@"settingView"];
    [self.revealSideViewController preloadViewController:leftBar forSide:PPRevealSideDirectionLeft];
    
    self.revealSideViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:self.revealSideViewController animated:YES completion:nil];
    //[self performSegueWithIdentifier:@"doLogin" sender:self];
}

- (void)prepare
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if([ud objectForKey:@"password"])
    {
        self.studentNumberTextField.hidden = YES;
        self.passwordTextField.hidden = YES;
        self.logo.hidden = NO;
        self.noticeLabel.hidden = YES;
        self.inputBG.hidden = YES;
        
        self.logo.alpha = 0;
        __block CGRect theframe = self.logo.frame;
        theframe.origin.y = 100;
        self.logo.frame = theframe;
        
        [UIView animateWithDuration:0.5f animations:^{
            theframe.origin.y += 5;
            self.logo.alpha = 1;
            self.logo.frame = theframe;
        } completion:^(BOOL finish)
        {
            [self performSelector:@selector(trans) withObject:nil afterDelay:0.1];
        }];
    }
    else
    {
        NSString *username = [ud objectForKey:@"username"];
        if(username)
        {
            self.studentNumberTextField.text = username;
            [self.passwordTextField becomeFirstResponder];
        }
        else
        {
            [self.studentNumberTextField becomeFirstResponder];
        }
        self.studentNumberTextField.hidden = NO;
        self.passwordTextField.hidden = NO;
        self.logo.hidden = NO;
        self.noticeLabel.hidden = NO;
        self.inputBG.hidden = NO;
        CGRect theframe = self.logo.frame;
        theframe.origin.y = 25;
        self.logo.frame = theframe;
        self.logo.alpha = 1;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self prepare];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self prepare];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setStudentNumberTextField:nil];
    [self setPasswordTextField:nil];
    [self setLogo:nil];
    [self setNoticeLabel:nil];
    [self setInputBG:nil];
    [super viewDidUnload];
}


- (void)showNotification:(NSString*)notice
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = notice;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];

}


- (void)checkValidation
{
    loginModel = [[LogInModal alloc] init];
    loginModel.password = self.passwordTextField.text;
    loginModel.userName = self.studentNumberTextField.text;
    loginModel.delegate = self;
    [loginModel start];
}


-(void)save
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:self.studentNumberTextField.text forKey:@"username"];
    NSString *pwd = [NSString stringByEncryptString:self.passwordTextField.text];
    if(![[NSString stringByDecryptString:pwd] isEqualToString:self.passwordTextField.text])
    {
        NSLog(@"FATAL ERROR!!!!! Decrypt pwd failed");
    }
    
    [ud setObject:pwd forKey:@"password"];
    [ud synchronize];
}



-(void)finishedLoading:(NSString*)category
{
    [MBProgressHUD hideHUDForView:self.view.window animated:YES];
    
    [self save];

    [self trans];
    
//    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainView"];
//    
//    
//    [UIView beginAnimations:@"View Flip" context:nil];
//    [UIView setAnimationDuration:0.80];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
//                           forView:self.view cache:NO];
//    
//    [self.view.superview addSubview:vc.view];
//    [self.view removeFromSuperview];
//    //[self.navigationController pushViewController:vc animated:YES];
//    [UIView commitAnimations];
//    
//    
////    [UIView transitionFromView:self.view
////                        toView:vc.view
////                      duration:0.5
////                       options:UIViewAnimationOptionTransitionFlipFromLeft
////                    completion:nil];
}

-(void)errorLoading:(NSError*)error
{
    
    if([error.domain isEqualToString:@"AccountOrPwdInvalid"])
    {
        [self showNotification:@"错误的账号或密码"];
        [MBProgressHUD hideHUDForView:self.view.window animated:YES];
    }

}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.passwordTextField resignFirstResponder];
    
    if([self.studentNumberTextField.text isEqualToString:@""])
    {
        [self showNotification:@"请输入学号"];
        return YES;
    }
    if([self.passwordTextField.text isEqualToString:@""])
    {
        [self showNotification:@"请输入密码"];
        return YES;
    }
    if(![[ReachabilityChecker instance] hasInternetAccess])
    {
        [self showNotification:@"没有网络连接"];
        return YES;
    }
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    //HUD.mode = MBProgressHUDModeAnnularDeterminate;
    HUD.labelText = @"正在验证...";
    HUD.dimBackground = YES;
    
    //[self performSelectorOnMainThread:@selector(checkValidation) withObject:nil];
    [self performSelectorOnMainThread:@selector(checkValidation) withObject:nil waitUntilDone:NO];

    return YES;
}

@end
