//
//  SearchViewController.h
//  TongjiXuanke
//
//  Created by Song on 13-1-1.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCAutocompletingSearchViewControllerDelegate.h"
#import "JCAutocompletingSearchViewController.h"
#import "SearchCategorySelectionViewController.h"
#import "PopoverView.h"

@interface SearchViewController : UIViewController<PopoverViewDelegate,JCAutocompletingSearchViewControllerDelegate>
{
    JCAutocompletingSearchViewController* searchController;
    SearchCategorySelectionViewController* categorySelection;
}
@property (weak, nonatomic) IBOutlet UIView *mainView;
@end
