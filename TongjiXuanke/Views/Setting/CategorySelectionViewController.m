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
//#define TXT_BEGIN "没有你想要的信息？"
//#define TXT_LINK "请反馈给我们"
//    NSString* txt = @ TXT_BEGIN TXT_LINK ; //
//	/**(1)** Build the NSAttributedString *******/
//	NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:txt];
//	// for those calls we don't specify a range so it affects the whole string
//	[attrStr setFont:[UIFont fontWithName:@"Helvetica" size:18]];
//	[attrStr setTextColor:[UIColor grayColor]];
//    [attrStr setTextAlignment:kCTJustifiedTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
//    
//	// and add a link to the "share your food!" text
//    [attrStr setLink:[NSURL URLWithString:@"mailto:tongzhizaozhidao@126.com"] range:[txt rangeOfString:@TXT_LINK]];
//    
//	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
//	OHAttributedLabel *label = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor darkGrayColor];
//    label.shadowOffset = CGSizeMake(0, -1);
//    label.shadowColor = [UIColor whiteColor];
//    label.attributedText = attrStr;
//    
//    //self.customLinkDemoLabel.attributedText = attrStr;
//    return label;
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
