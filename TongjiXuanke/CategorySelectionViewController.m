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


- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureNavBar {
    UIBarButtonItem *backButton = [UIBarButtonItem getBackButtonItemWithTitle:@"返回" target:self action:@selector(clickBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"没有你的学院？通过邮件反馈给我们，告诉我们贵学院通知的网址，我们将尽快推出";
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [[SettingModal instance] numberOfCategory])
        return;
        
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL selected = cell.accessoryType == UITableViewCellAccessoryNone ? NO : YES;
    selected = !selected;
    if([[SettingModal instance] setSubscribleCategoryAtIndex:indexPath.row to:selected])
    {
        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
