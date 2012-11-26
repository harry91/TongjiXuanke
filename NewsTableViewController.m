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
#import "MyDataStorage.h"
#import "News.h"
#import "Category.h"
#import "NSString+TimeConvertion.h"
#import "NewsDetailViewController.h"
#import "SettingModal.h"
#import "ReachabilityChecker.h"
#import "SSEModel.h"
#import "APNSManager.h"
#import "UIBarButtonItem+Addtion.h"
#import "CKRefreshControl.h"
#import "UIApplication+Toast.h"
#import "NSNotificationCenter+Xuanke.h"


@interface NewsTableViewController ()

@end

@implementation NewsTableViewController

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Helper Methods

- (void)configureNavBar
{
    UILabel *titleLabel = [UILabel getNavBarTitleLabel:@"通知早知道"];
    self.navigationItem.titleView = titleLabel;

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


- (void)configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath {
    
    //AnswerCellModel *cellModel = [[AnswerTableModel sharedModel] cellModelAtIndex:indexPath.row];
    
    News *news = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NewsCell *cell = (NewsCell*) aCell;
    
    // Configure the cell...
    //NSInteger row = indexPath.row;
    //NSInteger section = indexPath.section;
    
    cell.title.text = news.title;
    cell.unreadIndicator.hidden = [news.haveread boolValue];
    cell.dateandtime.text = [NSString stringByConvertingTimeToAgoFormatFromDate:news.date];
    
    NSString *briefContentPlaceHolder;
    if(!news.briefcontent)
    {
        if(![[ReachabilityChecker instance] hasInternetAccess])
        {
            briefContentPlaceHolder = @"目前没有网络连接...";
        }
        else
        {
            if([[ReachabilityChecker instance] usingWIFI])
            {
                briefContentPlaceHolder = @"等待下载...";
            }
            else if(![[SettingModal instance] shouldDownloadAllContentWithoutWIFI])
            {
                briefContentPlaceHolder = @"将在连入WIFI后下载...";
            }
        }
    }
    cell.briefContent.text = news.briefcontent == nil ? briefContentPlaceHolder : news.briefcontent;
    cell.catagory.text = news.category.name;
    cell.favIndicator.hidden = ! [news.favorated boolValue];
    
    UIImage *selectedImage = [UIImage imageNamed:@"cellBG_selected.png"];
    UIImageView *selectedView = [[UIImageView alloc] initWithImage:selectedImage];
    
    [cell setSelectedBackgroundView:selectedView];
    
    UIImage *unselectedImage = [UIImage imageNamed:@"cellBG.png"];
    UIImageView *unselectedView = [[UIImageView alloc] initWithImage:unselectedImage];
    
    [cell setBackgroundView:unselectedView];

}


- (void)dataInit
{
    dataStorage = [MyDataStorage instance];
    self.managedObjectContext = dataStorage.managedObjectContext;
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}


- (void)configurePullToRefresh
{
    CKRefreshControl *refreshControl = [CKRefreshControl new];
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉以更新"];
    [refreshControl addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = (id)refreshControl;
    [NSNotificationCenter registerAllUpdateDoneNotificationWithSelector:@selector(stopLoading) target:self];
    [self startLoading];
}

- (void)doRefresh:(CKRefreshControl *)sender {
    NSLog(@"refreshing");
    [self startLoading];
}


- (void)wrongPassCode
{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle: @"账号验证失败"
                               message: @"您是不是更改过密码？"
                              delegate: self
                     cancelButtonTitle: @"重试"
                     otherButtonTitles: nil];
    [alert show];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavBar];
    [self configurePullToRefresh];
    [self dataInit];
    
    [[Brain instance] APNSStart];
    
    [NSNotificationCenter registerUserCheckFailNotificationWithSelector:@selector(wrongPassCode) target:self];
    
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
    
    if([Brain instance].refreshing)
    {
        [self.refreshControl beginRefreshing];
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}


- (void)viewDidUnload {
    //[self setTableView:nil];
    [super viewDidUnload];
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
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"newsCell"];

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}



#pragma mark - Table view delegate
- (void)pushToDetailViewWithNews:(News*)news
{
    [MBProgressHUD hideHUDForView:self.view.window animated:YES];
    NewsDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    
    [vc configureWithNews:news];
    
    NSLog(@"%@",self.navigationController);
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    News *news = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    if(!news.content)
    {
        if([[ReachabilityChecker instance] hasInternetAccess])
        {
            dispatch_async(kBgQueue, ^{
                int categoryIndex = [[SettingModal instance] indexOfCategoryWithName:news.category.name];
                [[Brain instance] requestedNewsWithCategoryIndex:categoryIndex url:news.url];
                while(!news.content);
                [self performSelectorOnMainThread:@selector(pushToDetailViewWithNews:) withObject:news waitUntilDone:YES];
            });
            HUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            //HUD.mode = MBProgressHUDModeAnnularDeterminate;
            HUD.labelText = @"正在载入";
            HUD.dimBackground = YES;
        }
        else
        {
            [UIApplication presentToast:@"没有网络连接"];
        }
    }
    else
    {
        [self pushToDetailViewWithNews:news];
    }
     
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark - NSFetchResultDelegate


- (NSString*)allFilterClause
{
    NSMutableString *str = [@"" mutableCopy];
    NSMutableArray *arr = [@[] mutableCopy];
    for(int i = 0; i < [[SettingModal instance] numberOfCategory]; i++)
    {
        if([[SettingModal instance] hasSubscribleCategoryAtIndex:i])
        {
            NSString * s = [NSString stringWithFormat:@" category.name == \"%@\" ",[[SettingModal instance] nameForCategoryAtIndex:i]];
            
            [arr addObject:s];
        }
    }
    for(int i = 0; i < arr.count; i++)
    {
        [str appendString:arr[i]];
        if(i+1 != arr.count)
            [str appendString:@"OR"];
    }
    return str;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *simplePredicate = nil;
    NSLog(@"now select: %@--%@",[SettingModal instance].currentHeader,[SettingModal instance].currentCategory);
//    if([SettingModal instance].currentCategory == nil || ([[SettingModal instance].currentCategory isEqualToString:@"全部"] &&[[SettingModal instance].currentHeader isEqualToString:@"列表"]))// show all
//    {
//        
//    }
    if([[SettingModal instance].currentHeader isEqualToString:@"列表"] && ![[SettingModal instance].currentCategory isEqualToString:@"全部"])// show all in a category
    {
        NSString *simplePredicateFormat = [NSString stringWithFormat:@"category.name == \"%@\"",[SettingModal instance].currentCategory];
        simplePredicate = [NSPredicate predicateWithFormat:simplePredicateFormat];
    }
    if([[SettingModal instance].currentHeader isEqualToString:@"收藏"] && [[SettingModal instance].currentCategory isEqualToString:@"全部"])// show all favorated.
    {
        NSString *simplePredicateFormat = [NSString stringWithFormat:@"favorated == TRUE AND (%@)", [self allFilterClause]];
        simplePredicate = [NSPredicate predicateWithFormat:simplePredicateFormat];
    }
    if([[SettingModal instance].currentHeader isEqualToString:@"收藏"] && ![[SettingModal instance].currentCategory isEqualToString:@"全部"])// show all favorated in a category
    {
        NSString *simplePredicateFormat = [NSString stringWithFormat:@"favorated == TRUE AND category.name == \"%@\"",[SettingModal instance].currentCategory];
        simplePredicate = [NSPredicate predicateWithFormat:simplePredicateFormat];
    }
    
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"News" inManagedObjectContext:_managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    if(!simplePredicate)
    {
        simplePredicate = [NSPredicate predicateWithFormat:[self allFilterClause]];
    }
    [fetchRequest setPredicate:simplePredicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView ;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - News Loader
//-(void)finishedLoading:(NSString*)category
//{
//    [self stopLoading];
//}
//
//-(void)errorLoading:(NSError*)error
//{
//    if([error.domain isEqualToString:@"AccountOrPwdInvalid"])
//    {
//        UIAlertView *alert =
//        [[UIAlertView alloc] initWithTitle: @"账号验证失败"
//                                   message: @"您是不是更改过密码？"
//                                  delegate: self
//                         cancelButtonTitle: @"重试"
//                         otherButtonTitles: nil];
//        [alert show];
//        
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        //[self performSegueWithIdentifier:@"backToLogin" sender:self];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    else if([error.domain isEqualToString:@"NSURLErrorDomain"])
//    {
//        [self stopLoading];
//        [UIApplication presentToast:error.localizedDescription];
//    }
//}


#pragma mark -

-(void)stopLoading
{
    _reloading = NO;
    [self.refreshControl endRefreshing];
}

-(void)startLoading
{
    if([[ReachabilityChecker instance] hasInternetAccess])
    {
        _reloading = YES;
        [[Brain instance] refresh];
    }
    else
    {
        [UIApplication presentToast:@"没有网络连接"];
        [self stopLoading];
    }
}


@end
