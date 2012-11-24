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
#import "Brain.h"
#import "MBProgressHUD.h"
#import "IIViewDeckController.h"

@class MyDataStorage;
@class SSEModel;

@interface NewsTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>
{
    MyDataStorage *dataStorage;
    MBProgressHUD *HUD;
    BOOL _reloading;
}
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
