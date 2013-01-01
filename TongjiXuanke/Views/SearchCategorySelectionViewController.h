//
//  SearchCategorySelectionViewController.h
//  TongjiXuanke
//
//  Created by Song on 13-1-1.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCategorySelectionViewController : UIViewController
{
    NSIndexPath *currentIndexPath;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet NSArray *cellInfos;
@property (strong, nonatomic) IBOutlet NSArray *headers;

@property (nonatomic,strong) NSString* currentCategory;
@property (nonatomic,strong) NSString* currentHeader;


@end
