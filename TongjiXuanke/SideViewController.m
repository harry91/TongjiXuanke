//
//  SideViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-11-7.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SideViewController.h"

@interface SideViewController ()

@end

@implementation SideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    UIImage *resizeableImage = [[UIImage imageNamed:@"sideBarBGTextile.png"] resizableImageWithCapInsets:inset];
    self.background.image = resizeableImage;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"I am Called!");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackground:nil];
    [super viewDidUnload];
}
@end
