//
//  NewsInfoViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-12-31.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import "Category.h"

@class NewsDetailViewController;

@interface NewsInfoViewController : UIViewController
{
    News *news;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) NewsDetailViewController *myparent;

- (void)configureWithNews:(News *)news;

- (IBAction)donePressed:(id)sender;

-(IBAction)copyLink:(id)sender;

@end
