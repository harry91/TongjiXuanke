//
//  NewsTableViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-10-14.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "XuankeModel.h"
#import "NewsLoaderProtocal.h"
#import "MyDataStorage.h"
#import "EGORefreshTableHeaderView.h"

@class MyDataStorage;

@interface NewsTableViewController : UITableViewController<NewsLoaderProtocal,NSFetchedResultsControllerDelegate,EGORefreshTableHeaderDelegate>
{
    XuankeModel *xuankeModel;
    MyDataStorage *dataStorage;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
