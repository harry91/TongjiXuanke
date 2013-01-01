//
//  SearchViewController.m
//  TongjiXuanke
//
//  Created by Song on 13-1-1.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "SearchViewController.h"
#import "IIViewDeckController.h"
#import "JCAutocompletingSearchViewController.h"
#import "UILabel+Addition.h"
#import "DataOperator.h"
#import "NewsDetailViewController.h"

@implementation SearchViewController

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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg_search.png"] forBarMetrics:UIBarMetricsDefault];
    
    UILabel *titleLabel = [UILabel getNavBarTitleLabel:@"搜索全部"];
    
    self.navigationItem.titleView = titleLabel;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavBar];
    
    searchController = [JCAutocompletingSearchViewController autocompletingSearchViewController];
    searchController.delegate = self;
       
    [self.mainView addSubview:searchController.view];
    
    
    categorySelection = [self.storyboard instantiateViewControllerWithIdentifier:@"searchCategorySelection"];
    
    self.viewDeckController.delegate = self;
}

- (void) showLeft
{
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

-(void) showCategorySelector
{
    [PopoverView showPopoverAtPoint:CGPointMake(10,32) inView:self.view withContentView:categorySelection.view delegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    UIImage *image = [UIImage imageNamed: @"SearchMenuIcon.png"];
    UIImageView *iView = [[UIImageView alloc] initWithImage:image];
    
    CGRect frame = iView.frame;
    frame.origin.x -= 7;
    frame.origin.y += 7.5;
    iView.frame = frame;
    
    UIButton *categoryFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    categoryFilter.frame = iView.frame;
    [categoryFilter setBackgroundImage:image forState:UIControlStateNormal];
    
    [categoryFilter addTarget:self action:@selector(showCategorySelector) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [v addSubview:categoryFilter];
    
    [searchController setSearchBarLeftView:v];
    searchController.searchBar.tintColor = [UIColor colorWithRed:28/255.0 green:135/255.0 blue:233/255.0 alpha:0.0];

    UIImageView *searchBarOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar_BG.png"]];
    //searchBarOverlay.frame = CGRectMake(-8, -2, 320, 48);
    [searchController.searchBar addSubview:searchBarOverlay];
    [searchController.searchBar sendSubviewToBack:searchBarOverlay];
    
    for (UIView *v in [searchController.searchBar subviews]) {
        
        if ([NSStringFromClass([v class]) isEqualToString:@"UISearchBarBackground"])
        {
            [searchController.searchBar sendSubviewToBack:v];
        }
        
        if ([NSStringFromClass([v class]) isEqualToString:@"UIImageView"] && v != searchBarOverlay)
        {
            [searchController.searchBar sendSubviewToBack:v];
        }
    }
    
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewDeckController.delegate = nil;
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}

- (void)viewDidUnload {
    [self setMainView:nil];
    [super viewDidUnload];
}








- (NSArray*) possibleItems {
    if(!sharedList)
    {
        NSManagedObjectContext *context = [[MyDataStorage instance] managedObjectContext];
        
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:
         [NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
        
        NSError *error;
        NSArray *matching = [context executeFetchRequest:fetchRequest error:&error];
        
        if(!matching)
        {
            NSLog(@"Error: %@",[error description]);
        }
        
        NSMutableArray *list = [@[] mutableCopy];
        
        News *item;
        for(item in matching)
        {
            if(item.content)
                [list addObject:item];
        }
        
        sharedList = [NSArray arrayWithArray:list];
    }
    return sharedList;
}

#pragma mark - JCAutocompletingSearchViewControllerDelegate Implementation

- (void) searchController:(JCAutocompletingSearchViewController*)searchController
    performSearchForQuery:(NSString*)query
       withResultsHandler:(JCAutocompletingSearchResultsHandler)resultsHandler {
    // Simulate the asynchronicity and delay of a web request...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* possibleItems = [self possibleItems];
        NSMutableArray* matchedItems = [NSMutableArray new];
        
        if(categorySelection.currentHeader == nil)
        {
            categorySelection.currentHeader = @"列表";
            categorySelection.currentCategory = @"全部";
        }
        
        News *item;
        for(item in possibleItems)
        {
            NSLog(@"Current: %@ %@",categorySelection.currentHeader,categorySelection.currentCategory);
            
            if(![categorySelection.currentCategory isEqualToString:@"全部"])
            {
                if(![item.category.name isEqualToString:categorySelection.currentCategory])
                    continue;
            }
            if([categorySelection.currentHeader isEqualToString:@"收藏"])
            {
                if(![item.favorated boolValue])
                    continue;
            }
            if([query isEqualToString:@""] || query == nil)
            {
                [matchedItems addObject:item];
                continue;
            }
            
            BOOL result = NO;
            if([item.briefcontent rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                result = YES;
            }
            if(result)
            {
                [matchedItems addObject:item];
                continue;
            }
            if([item.title rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [matchedItems addObject:item];
            }
        }

        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            resultsHandler(matchedItems);
        });
    });
}

- (void) searchControllerCanceled:(JCAutocompletingSearchViewController*)aSearchController {
    [searchController.searchBar resignFirstResponder];
}

- (void) searchController:(JCAutocompletingSearchViewController*)searchController
                tableView:(UITableView*)tableView
           selectedResult:(id)result {
    News *item = result;
    
    NewsDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    
    [vc configureWithNews:item];
    
    NSLog(@"%@",self.navigationController);
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

// Optional.
- (BOOL) searchControllerShouldPerformBlankSearchOnLoad:(JCAutocompletingSearchViewController*)searchController {
    return YES;
}

// Optional.
- (BOOL) searchController:(JCAutocompletingSearchViewController*)searchController shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView {
    UILabel *titleLabel = [UILabel getNavBarTitleLabel:@"搜索全部"];
    if(categorySelection.currentCategory)
    {
        NSString* str = categorySelection.currentCategory;
        if([categorySelection.currentHeader isEqualToString:@"收藏"])
        {
            str = [str stringByAppendingString:categorySelection.currentHeader];
        }
        str = [@"搜索" stringByAppendingString:str];
        titleLabel = [UILabel getNavBarTitleLabel:str];
    }
    
    self.navigationItem.titleView = titleLabel;
    
    [searchController redoSearch];
}

#pragma mark - IIViewDeckControllerDelegate Methods
- (BOOL)viewDeckControllerWillOpenLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated
{
    [searchController.searchBar resignFirstResponder];
    return YES;
}
@end
