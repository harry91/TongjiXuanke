//
//  NewsTableViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-10-14.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XuankeModel.h"
#import "NewsLoaderProtocal.h"

@interface NewsTableViewController : UIViewController<NewsLoaderProtocal>
{
    XuankeModel *xuankeModel;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
