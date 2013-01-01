//
//  SideViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-11-7.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHMenuCell.h"
#import "IIViewDeckController.h"

@interface SideViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;


@property (strong, nonatomic) IBOutlet NSArray *cellInfos;
@property (strong, nonatomic) IBOutlet NSArray *headers;

-(IBAction)settingClicked:(id)sender;
-(IBAction)searchClicked:(id)sender;


@end
