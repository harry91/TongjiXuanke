#import "JCAutocompletingSearchViewController.h"
#import "NewsCell.h"
#import "UISearchBar+CustomLeftView.h"
#import "News.h"
#import "NSString+TimeConvertion.h"
#import "Category.h"
#import "SettingModal.h"

@interface JCAutocompletingSearchViewController ()

@property (nonatomic) BOOL loading;
@property (strong, nonatomic) NSArray* results;

@end

@implementation JCAutocompletingSearchViewController {
  NSObject* loadingMutex;
  NSUInteger loadingQueueCount;
  NSUInteger searchCounter;
  NSUInteger currentlyDisplaySearchID;
  BOOL delegateManagesTableViewCells;
  BOOL searchesPerformedSynchronously;
}

+ (JCAutocompletingSearchViewController*) autocompletingSearchViewController {
  UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"JCAutocompletingSearchStoryboard" bundle:nil];
  return (JCAutocompletingSearchViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.results = @[];
    self.loading = NO;
    loadingMutex = [NSObject new];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.

  if ( self.delegate
       && [self.delegate respondsToSelector:@selector(searchControllerShouldPerformBlankSearchOnLoad:)]
       && [self.delegate searchControllerShouldPerformBlankSearchOnLoad:self]) {
    [self searchBar:self.searchBar textDidChange:@""];
  }
    
    [self initNoDataPlaceHolder];
    
    [self updateNoDataPlaceHolder];
}

- (void) setSearchBarLeftView:(UIView*)view
{
    [self.searchBar setSearchIconView:view];
}

- (void) viewDidUnload {
  [self setResultsTableView:nil];
  [self setSearchBar:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (self.delegate && [self.delegate respondsToSelector:@selector(searchController:shouldAutorotateToInterfaceOrientation:)]) {
    return [self.delegate searchController:self shouldAutorotateToInterfaceOrientation:interfaceOrientation];
  }
  return YES;
}

- (void) setDelegate:(NSObject<JCAutocompletingSearchViewControllerDelegate>*)delegate {
  _delegate = delegate;
  if (delegate && [delegate respondsToSelector:@selector(searchControllerUsesCustomResultTableViewCells:)]) {
    delegateManagesTableViewCells = [delegate searchControllerUsesCustomResultTableViewCells:self];
  } else {
    delegateManagesTableViewCells = NO;
  }

  if (delegate && [delegate respondsToSelector:@selector(searchControllerSearchesPerformedSynchronously:)]) {
    searchesPerformedSynchronously = [delegate searchControllerSearchesPerformedSynchronously:self];
  } else {
    searchesPerformedSynchronously = NO;
  }
}


// -------------------------------------------------
// Code originally from: http://stackoverflow.com/a/12406117/1114761

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

    
    
  // Search for Cancel button in searchbar, enable it and add key-value observer.
  for (id subview in [self.searchBar subviews]) {
    if ([subview isKindOfClass:[UIButton class]]) {
      [subview setEnabled:YES];
      [subview addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    }
  }
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  // Remove observer for the Cancel button in searchBar.
  for (id subview in [self.searchBar subviews]) {
    if ([subview isKindOfClass:[UIButton class]]) {
      //[subview removeObserver:self forKeyPath:@"enabled"];
    }
  }
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
  // Re-enable the Cancel button in searchBar.
  if ([object isKindOfClass:[UIButton class]] && [keyPath isEqualToString:@"enabled"]) {
    UIButton *button = object;
    if (!button.enabled)
      button.enabled = YES;
  }
}

// -------------------------------------------------

- (void) setLoading:(BOOL)loading {
  @synchronized(loadingMutex) {
    if (!searchesPerformedSynchronously) {
      NSArray* changedIndexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0]];
      BOOL wasPreviouslyLoading = _loading;
      _loading = loading;
      if (wasPreviouslyLoading && !loading) {
        // Remove loading cell.
        [self.resultsTableView beginUpdates];
        [self.resultsTableView deleteRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.resultsTableView endUpdates];
      } else if (!wasPreviouslyLoading && loading) {
        // Add loading cell.
        [self.resultsTableView beginUpdates];
        [self.resultsTableView insertRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.resultsTableView endUpdates];
      }
    } else {
      _loading = NO;
    }
  }
}

- (void) resetSelection {
  NSIndexPath* selectedRow = [self.resultsTableView indexPathForSelectedRow];
  if (selectedRow) {
    [self.resultsTableView deselectRowAtIndexPath:selectedRow animated:NO];
  }
}

- (void) setSearchBarTextAndPerformSearch:(NSString*)query {
  self.searchBar.text = query;
  [self searchBar:self.searchBar textDidChange:query];
}

- (void)redoSearch
{
    [self setSearchBarTextAndPerformSearch:self.searchBar.text ? self.searchBar.text : @""];
}

#pragma mark - UISearchBarDelegate Implementation

- (void) searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText {
  ++loadingQueueCount;
  ++searchCounter;
  NSUInteger searchID = searchCounter;
  __block BOOL searchResultsReturned = NO;
  [self setLoading:YES];

  [self.delegate searchController:self performSearchForQuery:searchText withResultsHandler:^(NSArray* searchResults) {
    NSAssert(!searchResultsReturned, @"JCAutocompletingSearchController: delegate called results handler more than once for the same search execution.");
    searchResultsReturned = YES;
    
    if (searchID >= currentlyDisplaySearchID) {
      currentlyDisplaySearchID = searchID;
      if (searchResults) {
        self.results = searchResults;
        [self.resultsTableView reloadData];
      }
    } else {
      NSLog(@"JCAutocompletingSearchController: received out-of-order search results; ignoring. (currently displayed: %i, searchID: %i", currentlyDisplaySearchID, searchID);
    }
    --loadingQueueCount;
    if (loadingQueueCount == 0) {
      [self setLoading:NO];
    }
  }];
    
    [self updateNoDataPlaceHolder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar*)searchBar {
  [self.delegate searchControllerCanceled:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [[SettingModal instance] didSearch:searchBar.text];
}


#pragma mark - UITableViewDelegate Implementation

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (delegateManagesTableViewCells) {
    return [self.delegate searchController:self tableView:self.resultsTableView heightForRowAtIndexPath:indexPath];
  } else {
    return 80;
  }
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  NSUInteger row = indexPath.row;
  if (self.loading) {
    if (row == 0) {
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
      return;
    } else {
      --row;
    }
  }

[self.delegate searchController:self
                      tableView:self.resultsTableView
                 selectedResult:[self.results objectAtIndex:row]];
    
    [[SettingModal instance] didSearch:self.searchBar.text];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


#pragma mark - UITableViewDataSource Implementation

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return self.results.count + (self.loading ? 1 : 0);
  } else {
    return 0;
  }
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  NSUInteger row = indexPath.row;
  if (self.loading) {
    if (row == 0) {
      return [self.resultsTableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    } else {
      --row;
    }
  }

  if (delegateManagesTableViewCells) {
    return [self.delegate searchController:self tableView:self.resultsTableView cellForRowAtIndexPath:indexPath];
  } else {
    if (row < self.results.count) {
      News* result = (News*)[self.results objectAtIndex:row];
      NewsCell* cell = (NewsCell*)[self.resultsTableView dequeueReusableCellWithIdentifier:@"ResultCell"];
      
        
        cell.title.text = result.title;
        cell.unreadIndicator.hidden = YES;
        cell.dateandtime.text = [NSString stringByConvertingTimeToAgoFormatFromDate:result.date];
        
        cell.briefContent.text = result.briefcontent;
        cell.catagory.text = result.category.name;
        cell.favIndicator.hidden = YES;
        
        UIImage *selectedImage = [UIImage imageNamed:@"cellBG_selected.png"];
        UIImageView *selectedView = [[UIImageView alloc] initWithImage:selectedImage];
        
        [cell setSelectedBackgroundView:selectedView];
        
//        UIImage *unselectedImage = [UIImage imageNamed:@"cellBG.png"];
//        UIImageView *unselectedView = [[UIImageView alloc] initWithImage:unselectedImage];
//        
//        [cell setBackgroundView:unselectedView];

      return cell;
    } else {
      return Nil;
    }
  }
}

- (void)updateNoDataPlaceHolder
{
    if([self tableView:self.resultsTableView numberOfRowsInSection:0] == 0)
    {
        self.noDataPlaceHolder.hidden = NO;
    }
    else
    {
        self.noDataPlaceHolder.hidden = YES;
    }
}

- (void)initNoDataPlaceHolder
{
    self.noDataPlaceHolder = [[UIView alloc] init];
    self.noDataPlaceHolder.frame = self.resultsTableView.frame;
    self.noDataPlaceHolder.backgroundColor = [UIColor clearColor];
    
    HotKeyWordsView *keywordView = [[HotKeyWordsView alloc]initWithFrame:CGRectMake(0, -44, 320, 500)];
    [self.noDataPlaceHolder addSubview:keywordView];
    keywordView.delegate = self;
    keywordView.tag = 4001;
    
    
    //NSMutableArray *keywordArray = [@[] mutableCopy];
    
    NSMutableArray *personalArray = [@[] mutableCopy];
    [personalArray addObject:[SettingModal instance].studentID];
    if([SettingModal instance].hasStudentProfileSet)
    {
        [personalArray addObject:[SettingModal instance].studentName];
    }
    NSDictionary *personal = @{@"name":@"  个人",@"words" : personalArray};
    
    
    NSArray *historyArray = [[SettingModal instance] searchHistory];
    if(!historyArray)
        historyArray = @[];
    NSDictionary *history = @{@"name":@"  历史",@"words" : historyArray};
    
    
    NSArray *keywordArray = @[personal,history];
    
    [keywordView setKeyWords:keywordArray];
    
    [self.resultsTableView addSubview:self.noDataPlaceHolder];
}

#pragma mark- KeyWordDelegate
- (void)selectOnKeyWord:(NSString *)word
{
    self.searchBar.text = word;
    [self searchBar:self.searchBar textDidChange:word];
}
@end


#pragma mark -
#pragma mark HotkeyWords

#define MARGIN 10
#define TOPMARGIN 44

@implementation HotKeyWordsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:240./256 green:240./256 blue:240./256 alpha:1.f];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = @"猜你会搜：";
        textLabel.textColor = [UIColor colorWithRed:90./256 green:90./256 blue:90./256 alpha:1];
        textLabel.font = [UIFont fontWithName:@"Arial" size:15];
        textLabel.shadowColor = [UIColor whiteColor];
        textLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:textLabel];
        
    }
    return self;
}



- (void)setKeyWords:(NSArray *)words
{
    int i = 0;
    CGRect frameOfLastButton = CGRectZero;
    float lastCategoryY = TOPMARGIN;
    
    for(NSDictionary *dict in words)
    {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, lastCategoryY+25 , 70, 20)];
        label.text = [dict objectForKey:@"name"];
        label.textColor = [UIColor colorWithRed:149./256 green:149./256 blue:149./256 alpha:1];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:label];
        label.backgroundColor = [UIColor clearColor];
        [label setFont:[UIFont fontWithName:@"GillSans" size:16]];
        
        int j = 0;
        for (NSString *word in [dict objectForKey:@"words"])
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:word forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:66./256 green:116./256 blue:205./256 alpha:1] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"GillSans" size:14];
            [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.shadowOffset = CGSizeMake(0, 1);
            CGSize size = [word sizeWithFont:[UIFont systemFontOfSize:14]];
            
            
            if(j!=0)
            {
                button.frame = CGRectMake(frameOfLastButton.origin.x + frameOfLastButton.size.width + MARGIN, frameOfLastButton.origin.y , size.width, size.height);
                
                if(button.frame.size.width + button.frame.origin.x > 320)
                {
                    button.frame = CGRectMake(70, frameOfLastButton.origin.y + 20, size.width, size.height);
                }
            }
            else
            {
                button.frame = CGRectMake(70, label.frame.origin.y , size.width, size.height);
            }
                
            [self addSubview:button];
            
            [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
            
            j++;
            frameOfLastButton = button.frame;

            lastCategoryY = button.frame.size.height + button.frame.origin.y;
        }
        
        i++;
        frameOfLastButton = CGRectZero;
    }
    
}

- (void)buttonPress:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(selectOnKeyWord:)])
    {
        [self.delegate selectOnKeyWord:sender.titleLabel.text];
    }
}

@end
