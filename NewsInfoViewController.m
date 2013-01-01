//
//  NewsInfoViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-12-31.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NewsInfoViewController.h"
#import "NSString+TimeConvertion.h"

@implementation NewsInfoViewController


- (void)viewDidLoad
{
    self.scrollView.contentSize = CGSizeMake(320, 260);
    self.departmentLabel.text = news.category.name;
    self.timeLabel.text = [NSString stringByConvertingTimeToAgoFormatFromDate:news.date];    self.titleLabel.text = news.title;
    
    
    [self.doneBtn addTarget:self.myparent action:@selector(dismissMySemiModalView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureWithNews:(News *)aNews {
    news = aNews;
}

-(IBAction)copyLink:(id)sender
{
    
}

- (IBAction)donePressed:(id)sender
{
//    UIViewController * parent = [self.view containingViewController];
//    if ([parent respondsToSelector:@selector(dismissSemiModalView)]) {
//        [parent dismissSemiModalView];
//    }
}

- (void)viewDidUnload {
    [self setBackground:nil];
    [self setTimeLabel:nil];
    [self setTitleLabel:nil];
    [self setDepartmentLabel:nil];
    [self setScrollView:nil];
    [self setDoneBtn:nil];
    [super viewDidUnload];
}
@end
