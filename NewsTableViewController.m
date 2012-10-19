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
    UILabel *titleLabel = [UILabel getNavBarTitleLabel:@"选课网通知"];
    self.navigationItem.titleView = titleLabel;
}

- (void)configureModel
{
    xuankeModel = [[XuankeModel alloc] init];
    xuankeModel.password = @"21434909cbfv";
    xuankeModel.userName = @"102890";
    xuankeModel.delegate = self;
    
    self.tableView.contentInset = UIEdgeInsetsMake(66.0f, 0.0f, 0.0f, 0.0f);
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging: self.tableView];
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
    cell.dateandtime.text = [NSString strTimeAgoFromDate:news.date];
    
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
                briefContentPlaceHolder = @"正在下载...";
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
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    view.delegate = self;
    [self.tableView addSubview:view];
    _refreshHeaderView = view;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavBar];
    [self configurePullToRefresh];
    [self configureModel];
    
    
    [self dataInit];
        // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
- (void)pushToDetailViewWithNews:(News*)news
{
    NewsDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    
    [vc configureWithNews:news];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    News *news = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    if(!news.content)
    {
        dispatch_async(kBgQueue, ^{
            [xuankeModel retreiveDetailForUrl:news.url];
            while(!news.content);
            [self performSelectorOnMainThread:@selector(pushToDetailViewWithNews:) withObject:news waitUntilDone:YES];
        });
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


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"News" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
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
-(void)finishedLoading
{
    //[self.tableView reloadData];
    if([[ReachabilityChecker instance] hasInternetAccess])
    {
        if([[ReachabilityChecker instance] usingWIFI] || [[SettingModal instance] shouldDownloadAllContentWithoutWIFI])
        {
            [xuankeModel retreiveDetails];
        }
    }
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

-(void)errorLoading:(NSError*)error
{
    NSLog(@"Error:%@",error.domain);
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods


-(void)startLoading
{
    _reloading = YES;
    [xuankeModel start];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self startLoading];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
