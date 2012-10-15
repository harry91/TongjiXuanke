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

@class MyDataStorage;

@interface NewsTableViewController : UIViewController<NewsLoaderProtocal,NSFetchedResultsControllerDelegate>
{
    XuankeModel *xuankeModel;
    MyDataStorage *dataStorage;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
