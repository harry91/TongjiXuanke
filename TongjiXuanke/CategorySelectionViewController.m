//
//  CategorySelectionViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-11-5.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "CategorySelectionViewController.h"
#import "UIBarButtonItem+Addtion.h"
#import "SettingModal.h"
#import "MBProgressHUD.h"
#import "ReachabilityChecker.h"
#import "Brain.h"
#import "NSNotificationCenter+Xuanke.h"

@interface CategorySelectionViewController ()

@end

@implementation CategorySelectionViewController

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

    [self configureNavBar];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [NSNotificationCenter postCategoryChangedNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureNavBar {
    backButton = [UIBarButtonItem getBackButtonItemWithTitle:@"返回" target:self action:@selector(clickBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
}


-(void)showNoInternetNotification
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = @"设置失败，请检查网络连接";
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	
	[hud hide:YES afterDelay:3];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // Return the number of rows in the section.
    return [[SettingModal instance] numberOfCategory] + 1;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    NSMutableAttributedString *string; // assume string exists
//    NSRange selectedRange; // assume this is set
//    
//    NSURL *linkURL = [NSURL URLWithString:@"mailto:tongzhizaozhidao@126.com"];
//    
//    [string beginEditing];
//    [string addAttribute:NSLinkAttributeName
//                   value:linkURL
//                   range:selectedRange];
//    
//    [string addAttribute:NSForegroundColorAttributeName
//                   value:[NSColor blueColor]
//                   range:selectedRange];
//    
//    [string addAttribute:NSUnderlineStyleAttributeName
//                   value:[NSNumber numberWithInt:NSSingleUnderlineStyle]
//                   range:selectedRange];
//    [string endEditing];
//}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"没有你想要的信息？请反馈给我们";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row == [[SettingModal instance] numberOfCategory])
    {
        cell = [tableView
                dequeueReusableCellWithIdentifier:@"categoryWaitingCell"];
    }
    else
    {
        cell = [tableView
                dequeueReusableCellWithIdentifier:@"categoryCell"];
        
        cell.accessoryType = [[SettingModal instance] hasSubscribleCategoryAtIndex:indexPath.row] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        label.text = [[SettingModal instance] nameForCategoryAtIndex:indexPath.row];
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [[SettingModal instance] numberOfCategory])
        return;
    
//    if(![[ReachabilityChecker instance] hasInternetAccess])
//    {
//        [self showNoInternetNotification];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        return;
//    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL selected = cell.accessoryType == UITableViewCellAccessoryNone ? NO : YES;
    selected = !selected;
    
    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

    dispatch_async(kBgQueue, ^{
        [[SettingModal instance] setSubscribleCategoryAtIndex:indexPath.row to:selected];
    });
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([[SettingModal instance] subscribledCount] == 0)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = backButton;
    }
}

@end
