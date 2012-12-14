//
//  SettingTableViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-11-4.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SettingTableViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "SocialShareModal.h"
#import "SettingModal.h"
#import "IIViewDeckController.h"
#import "NSNotificationCenter+Xuanke.h"
#import "DataOperator.h"

#define RECOMMAND_TEXT @"我刚刚用了同济通知早知道，再也不用担心错过选课网上的通知啦。特有通知推送和离线查看功能，推荐你也来用。下载地址: http://sbhhbs.com/tzzzd_dl.php"

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)configureData
{
    if([[SettingModal instance] hasStudentProfileSet])
    {
        self.usernameLabel.text =  [SettingModal instance].studentName;
    }
    else
    {
        self.usernameLabel.text = [SettingModal instance].studentID;
    }
    
    [self setAutoCleanTime: [[SettingModal instance] autoCleanInterval]];
    
    [self.onlyWIFIdownloadSwtich setOn:![[SettingModal instance] shouldDownloadAllContentWithoutWIFI]];
    
    [self.onlyWIFIdownloadSwtich addTarget:self action:@selector(downloadSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.categoryLabel.text = [NSString stringWithFormat:@"已选择%d个",[[SettingModal instance] subscribledCount]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self configureData];
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}

- (void)configureNavBar
{
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIImage *icon = [UIImage imageNamed:@"nav_menu_icon.png"];
    [button setImage:icon forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = result;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg.png"] forBarMetrics:UIBarMetricsDefault];

}

- (void) showLeft
{
    [self.viewDeckController toggleLeftViewAnimated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureNavBar];
    
    [NSNotificationCenter registerUpgradeProNotificationWithSelector:@selector(showBuyResult:) target:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Account Methods
- (void)logout
{
    UIActionSheet* actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登陆" otherButtonTitles:nil];
    
    logoutActionSheet = actionSheet;
    [actionSheet showInView:self.view];
}

-(void)downloadSwitchChanged:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    [[SettingModal instance] setShouldDownloadAllContentWithoutWIFI:!isButtonOn];
}

- (void)setAutoCleanTime:(int)month
{
    NSString *text;
    if(month == 0)
    {
        text = @"从不";
    }
    else
    {
        text = [NSString stringWithFormat:@"%d个月前",month];
    }
    self.autoCleanTimeLabel.text = text;
    [[SettingModal instance] setAutoCleanInterval:month];
    [[DataOperator instance] cleanUpExpireNews];
    [self cleanTableSelection];
}

- (void)autoCleanShowPicker
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [self setAutoCleanTime:selectedIndex];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"AutoClean Picker Canceled");
        [self cleanTableSelection];
    };
    
    NSArray *months = @[@"从不", @"1个月前",@"2个月前",@"3个月前",@"4个月前",@"5个月前",@"6个月前",@"7个月前",@"8个月前",@"9个月前",@"10个月前",@"11个月前",@"12个月前"];
    
    [ActionSheetStringPicker showPickerWithTitle:@"自动清除" rows:months initialSelection:[[SettingModal instance] autoCleanInterval] doneBlock:done cancelBlock:cancel origin:self.autoCleanCell];
}


#pragma mark - About Methods
-(void)sendSuggestionEmail
{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"未设置邮件帐户", nil)
                                                        message:NSLocalizedString(@"可以在Mail中添加您的邮件帐户", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"好的", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        
        
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        

        // Get the users Device Model, Display Name, Unique ID, Token & Version Number
        UIDevice *dev = [UIDevice currentDevice];
        NSString *deviceModel = [dev platformString];
        
        NSString *deviceSystemVersion = dev.systemVersion;

        
        
        NSString *subject = [NSString stringWithFormat:@"同济通知早知道 v%@ 用户反馈",appVersion];
        
        NSString *receiver = [NSString stringWithFormat:@"tongzhizaozhidao@126.com"];
        [picker setToRecipients:[NSArray arrayWithObject:receiver]];
        
        [picker setSubject:subject];
        NSString *emailBody = [NSString stringWithFormat:@"设备描述：\n   型号： %@\n   版本： %@\n\n您的宝贵意见：\n\n",deviceModel,deviceSystemVersion];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
//        [[[UIApplication sharedApplication] delegate].window.rootViewController presentModalViewController:picker animated:YES];
    }
    
    [self cleanTableSelection];
}

-(void)rateMe
{
    NSString* appid = [NSString stringWithFormat:@"576480303"];
    
    NSString* url = [NSString stringWithFormat:  @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8", appid];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    
    [self cleanTableSelection];
}


-(void)tellFriend
{
    UIActionSheet* actionSheet;
    if([SocialShareModal socialShareAvailable])
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信分享", @"邮件分享",@"微博分享", nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信分享", @"邮件分享", nil];
    }
    //UITabBar* tabBar = self.viewDeckController.centerController.tabBarController.tabBar;
    shareActionSheet = actionSheet;
    [actionSheet showInView:self.view];
//  [actionSheet showFromTabBar:tabBar];
    
    [self cleanTableSelection];
}





#pragma mark - Table view delegate

- (void)cleanTableSelection
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == self.tellFriendCell)
    {
        [self tellFriend];
    }
    else if(cell == self.suggestionCell)
    {
        [self sendSuggestionEmail];
    }
    else if(cell == self.rateMeCell)
    {
        [self rateMe];
    }
    else if(cell == self.usernameCell)
    {
        [self logout];
    }
    else if(cell == self.autoCleanCell)
    {
        [self autoCleanShowPicker];
    }
    
}

- (void)viewDidUnload {
    [self setUsernameLabel:nil];
    [self setCategoryCell:nil];
    [self setCategoryLabel:nil];
    [self setOnlyWIFIdownloadSwtich:nil];
    [self setRateMeCell:nil];
    [self setTellFriendCell:nil];
    [self setSuggestionCell:nil];
    [self setUsernameCell:nil];
    [self setAutoCleanCell:nil];
    [self setAutoCleanTimeLabel:nil];
    [super viewDidUnload];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    NSString *message = nil;
    switch (result)
    {
        case MFMailComposeResultCancelled: {
//            message = NSLocalizedString(@"发送取消", nil);
            [self dismissModalViewControllerAnimated:YES];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
//                                                                message:nil
//                                                               delegate:nil
//                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                                      otherButtonTitles:nil];
//            [alertView show];
            break;
        }
        case MFMailComposeResultSaved: {
//            message = NSLocalizedString(@"保存成功", nil);
            [self dismissModalViewControllerAnimated:YES];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
//                                                                message:nil
//                                                               delegate:nil
//                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                                      otherButtonTitles:nil];
//            [alertView show];
            break;
        }
        case MFMailComposeResultSent: {
//            message = NSLocalizedString(@"发送成功", nil);
////            [((RKTabBarController*)[[UIApplication sharedApplication] delegate].window.rootViewController) dismissModalViewControllerAnimated:YES];
            [self dismissModalViewControllerAnimated:YES];
//
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
//                                                                message:NSLocalizedString(@"感谢您的使用！", nil)
//                                                               delegate:nil
//                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                                      otherButtonTitles:nil];
//            [alertView show];
            break;
        }
        case MFMailComposeResultFailed: {
            message = NSLocalizedString(@"发送失败", nil);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            break;
        }
        default: {
            return;
        }
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    NSString *message = nil;
    switch (result)
    {
        case MessageComposeResultCancelled: {
//            message = NSLocalizedString(@"您已取消发送", nil);
            [self dismissModalViewControllerAnimated:YES];
//
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
//                                                                message:nil
//                                                               delegate:nil
//                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                                      otherButtonTitles:nil];
//            [alertView show];
            break;
        }
        case MessageComposeResultSent: {
//            message = NSLocalizedString(@"发送成功", nil);
            [self dismissModalViewControllerAnimated:YES];
//
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
//                                                                message:NSLocalizedString(@"感谢您的使用", nil)
//                                                               delegate:nil
//                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                                      otherButtonTitles:nil];
//            [alertView show];
            break;
        }
        case MessageComposeResultFailed: {
            message = NSLocalizedString(@"发送失败", nil);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            break;
        }
        default: {
            return;
        }
    }
}

#pragma mark - Buy methods

- (void)alreadyProversionAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您已经是尊贵的专业版。"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    [self cleanTableSelection];
}


- (void)showBuyResult:(NSNotification *)notification
{
    NSNumber *result = notification.object;
    BOOL r = [result boolValue];
    NSString *message;
    if(r)
    {
        message = @"升级成功！";
    }
    else
    {
        message = @"升级失败！";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                          otherButtonTitles:nil];
    [alertView show];
    [self cleanTableSelection];
}

#pragma mark - Share methods
- (void)shareByWeibo
{
    SocialShareModal *socialModal = [[SocialShareModal alloc] init];
    socialModal.targetViewController = self;
    socialModal.postText = RECOMMAND_TEXT;
    
    UIImage *image = [UIImage imageNamed:@"ads.png"];
    socialModal.postImageList = @[image];
    [socialModal sendWeiboMessage];
}

- (void)shareByMessage
{
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无法发送信息", nil)
                                                        message:NSLocalizedString(@"可", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"好", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        MFMessageComposeViewController* picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        NSString *body = [NSString stringWithFormat:RECOMMAND_TEXT];
        [picker setBody:body];
        [self presentModalViewController:picker animated:YES];
    }
}

- (void)shareByMail
{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"未设置邮件帐户", nil)
                                                        message:NSLocalizedString(@"可以在Mail中添加您的邮件帐户", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"好", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        NSString *subject = [NSString stringWithFormat:@"推荐你使用通知早知道"];
        [picker setSubject:subject];
        
        NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"recommand_email" ofType:@"html"];
        NSString *infoText = [[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"Content: %@",infoText);
        [picker setMessageBody:infoText isHTML:YES];
        [self presentModalViewController:picker animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == shareActionSheet)
    {
        switch (buttonIndex) {
            case 0:
            {
                [self shareByMessage];
                
                break;
            }
            case 1:
            {
                [self shareByMail];
                
                break;
            }
            case 2:
            {
                if([SocialShareModal socialShareAvailable])
                    [self shareByWeibo];
                
                break;
            }
            default:
                break;
        }
    }
    if(actionSheet == logoutActionSheet)
    {
        switch (buttonIndex) {
            case 0:
            {
                [[SettingModal instance] doLogoutCleanUp];
                [self dismissViewControllerAnimated:YES completion:nil];

                NSLog(@"Logout");
                break;
            }
            default:
                break;
        }
    }
    
    [self cleanTableSelection];
}


@end
