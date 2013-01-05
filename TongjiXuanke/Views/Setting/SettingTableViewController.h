//
//  SettingTableViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-11-4.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ActionSheetPicker.h"
#import "CMActionSheet.h"

@interface SettingTableViewController : UITableViewController<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UISwitch *onlyWIFIdownloadSwtich;
@property (weak, nonatomic) IBOutlet UITableViewCell *rateMeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *tellFriendCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *suggestionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *autoCleanCell;
@property (weak, nonatomic) IBOutlet UILabel *autoCleanTimeLabel;

@end
