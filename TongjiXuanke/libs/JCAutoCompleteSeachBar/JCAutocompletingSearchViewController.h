#import <UIKit/UIKit.h>
#import "JCAutocompletingSearchViewControllerDelegate.h"

@protocol KeyWordDelegate <NSObject>

- (void)selectOnKeyWord:(NSString*)word;

@end

@class HotKeyWordsView;

@interface HotKeyWordsView : UIView

@property (nonatomic,assign) id<KeyWordDelegate>delegate;
- (void)setKeyWords:(NSArray*)words;

@end

@interface JCAutocompletingSearchViewController : UIViewController <KeyWordDelegate,UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSObject<JCAutocompletingSearchViewControllerDelegate>* delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;
@property (strong, nonatomic) IBOutlet UIView *noDataPlaceHolder;

+ (JCAutocompletingSearchViewController*) autocompletingSearchViewController;

- (void) resetSelection;
- (void) setSearchBarTextAndPerformSearch:(NSString*)query;

- (void) setSearchBarLeftView:(UIView*)view;

- (void)redoSearch;

@end

