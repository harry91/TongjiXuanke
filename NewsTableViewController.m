//
//  NewsTableViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-10-14.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NewsTableViewController.h"
#import "NewsCell.h"
#import "UILabel+Addition.h"

@interface NewsTableViewController ()

@end

@implementation NewsTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureNavBar
{
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    UILabel *titleLabel = [UILabel getNavBarTitleLabel:@"选课网通知"];
    self.navigationItem.titleView = titleLabel;
}

- (void)configureModel
{
    xuankeModel = [[XuankeModel alloc] init];
    xuankeModel.password = @"21434909cbfv";
    xuankeModel.userName = @"102890";
    xuankeModel.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureModel];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [xuankeModel totalNewsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"newsCell"];

    // Configure the cell...
    NSInteger row = indexPath.row;
    //NSInteger section = indexPath.section;
    
    cell.title.text = [xuankeModel titleForNewsIndex:row];
    cell.unreadIndicator.hidden = YES;
    cell.dateandtime.text = [xuankeModel timeForNewsIndex:row];
    cell.briefContent.text = @"正在载入...";
    cell.catagory.text = [xuankeModel catagoryForNewsIndex:row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - news loader
-(void)finishedLoading
{
    [self.tableView reloadData];
}

-(void)errorLoading:(NSError*)error
{
    NSLog(@"Error:%@",error.domain);
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
