//
//  SearchCategorySelectionViewController.h
//  TongjiXuanke
//
//  Created by Song on 13-1-1.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchCategoryListener <NSObject>

- (void)categoryDidChangeWithHeader:(NSString*)header andCategory:(NSString*)category;

@end

@interface SearchCategorySelectionViewController : UIViewController
{
    NSIndexPath *currentIndexPath;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet NSArray *cellInfos;
@property (strong, nonatomic) IBOutlet NSArray *headers;

@property (nonatomic,strong) NSString* currentCategory;
@property (nonatomic,strong) NSString* currentHeader;

@property (nonatomic,retain) id<SearchCategoryListener> delegate;

@end
