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

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.usernameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Account Methods
-(void)logout
{
    UIActionSheet* actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登陆" otherButtonTitles:nil];
    
    UITabBar* tabBar = self.tabBarController.tabBar;
    logoutActionSheet = actionSheet;
    [actionSheet showFromTabBar:tabBar];
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
        
        NSString *receiver = [NSString stringWithFormat:@"cbfvcbfv@126.com"];
        [picker setToRecipients:[NSArray arrayWithObject:receiver]];
        
        [picker setSubject:subject];
        NSString *emailBody = [NSString stringWithFormat:@"设备描述：\n   型号： %@\n   版本： %@\n\n您的宝贵意见：\n\n",deviceModel,deviceSystemVersion];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
//        [[[UIApplication sharedApplication] delegate].window.rootViewController presentModalViewController:picker animated:YES];
    }
}

-(void)rateMe
{
    NSString* appid = [NSString stringWithFormat:@"507861904"];
    
    //TODO change appid
    
    NSString* url = [NSString stringWithFormat:  @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8", appid];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
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
    UITabBar* tabBar = self.tabBarController.tabBar;
    shareActionSheet = actionSheet;
    [actionSheet showFromTabBar:tabBar];
}

#pragma mark - Table view delegate

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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
//            [self dismissModalViewControllerAnimated:YES];
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
//            [self dismissModalViewControllerAnimated:YES];
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
//            [self dismissModalViewControllerAnimated:YES];
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
//            [self dismissModalViewControllerAnimated:YES];
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
//            [self dismissModalViewControllerAnimated:YES];
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

#pragma mark - Share methods

- (void)shareByWeibo
{
    SocialShareModal *socialModal = [[SocialShareModal alloc] init];
    socialModal.targetViewController = self.tabBarController;
    socialModal.postText = @"我刚刚用了同济通知早知道，再也不用担心错过选课网上的通知啦。通知推送+离线查看 贴心，放心^^。 推荐你也来用。";
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
        
        NSString *body = [NSString stringWithFormat:@"我刚刚用了同济通知早知道，再也不用担心错过选课网上的通知啦。通知推送+离线查看 贴心，放心^^。 推荐你也来用。"];
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
        NSString *emailBody = [NSString stringWithFormat:@"我刚刚用了同济通知早知道，再也不用担心错过选课网上的通知啦。通知推送+离线查看 贴心，放心^^。 推荐你也来用。"];
        [picker setMessageBody:emailBody isHTML:NO];
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
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //[self performSegueWithIdentifier:@"backToLogin" sender:self];
                [self dismissViewControllerAnimated:YES completion:nil];

                //NSLog(@"Logout");
                break;
            }
            default:
                break;
        }
    }
}


@end
