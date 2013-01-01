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
    static NSArray* sharedList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Random names courtesy of http://www.kleimo.com/random/name.cfm
        sharedList = [@[
                      @"Debbie Cawthon", @"Philip Mahan", @"Susie Sloan", @"Melinda Wurth", @"Flora Bible",
                      @"Marlene Collier", @"John Trammell", @"Kristina Chun", @"Linda Caldera", @"Veronica Jaime",
                      @"Rosie Melo", @"Joyce Vella", @"Douglas Leger", @"Brandon Koon", @"Rachel Peeples",
                      @"Vicki Castor", @"Benjamin Lynch", @"Velma Vann", @"Della Sherrer", @"Aaron Lyle",
                      @"Arthur Jonas", @"Irma Atwood", @"Randy Cheatham", @"Billy Voyles", @"Michele Crouch",
                      @"Kenneth Shankle", @"Fred Anglin", @"Dennis Fries", @"Lillie Albertson", @"Iris Bertram"
                      ] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                          return [(NSString*)obj1 compare:(NSString*)obj2];
                      }];
    });
    return sharedList;
}

#pragma mark - JCAutocompletingSearchViewControllerDelegate Implementation

- (void) searchController:(JCAutocompletingSearchViewController*)searchController
    performSearchForQuery:(NSString*)query
       withResultsHandler:(JCAutocompletingSearchResultsHandler)resultsHandler {
    // Simulate the asynchronicity and delay of a web request...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* possibleItems = [self possibleItems];
        
        NSMutableArray* predicates = [NSMutableArray new];
        for (__strong NSString* queryPart in [query componentsSeparatedByString:@" "]) {
            if (queryPart && (queryPart = [queryPart stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length > 0) {
                [predicates addObject:[NSPredicate predicateWithFormat:@"SELF like[cd] %@", [NSString stringWithFormat:@"*%@*", queryPart]]];
            }
        }
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        NSArray* matchedItems = [possibleItems filteredArrayUsingPredicate:predicate];
        NSMutableArray* results = [NSMutableArray new];
        for (NSString* item in matchedItems) {
            [results addObject:@{@"label": item}];
        }
        
        double delayInSeconds = 0.4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            resultsHandler(results);
        });
    });
}

- (void) searchControllerCanceled:(JCAutocompletingSearchViewController*)aSearchController {
    [searchController.searchBar resignFirstResponder];
}

- (void) searchController:(JCAutocompletingSearchViewController*)searchController
                tableView:(UITableView*)tableView
           selectedResult:(id)result {
    NSString* resultLabel = [(NSDictionary*)result objectForKey:@"label"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Result Selected"
                                                    message:[NSString stringWithFormat:@"Tapped result: %@", resultLabel]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
}

#pragma mark - IIViewDeckControllerDelegate Methods
- (BOOL)viewDeckControllerWillOpenLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated
{
    [searchController.searchBar resignFirstResponder];
    return YES;
}
@end
