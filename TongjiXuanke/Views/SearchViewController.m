//
//  SearchViewController.m
//  TongjiXuanke
//
//  Created by Song on 13-1-1.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "SearchViewController.h"
#import "IIViewDeckController.h"

@implementation SearchViewController

- (void)configureNavBar
{
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIImage *icon = [UIImage imageNamed:@"nav_menu_icon.png"];
    [button setImage:icon forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = result;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavBar];
    
}

- (void) showLeft
{
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}

- (void)viewDidUnload {
    [self setMainView:nil];
    [super viewDidUnload];
}
@end
