//
//  HelpViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-11-28.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "HelpViewController.h"
#import "SettingModal.h"
#import "UIImage+StackBlur.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

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
	// Do any additional setup after loading the view.
    [self.scrollView setContentSize:CGSizeMake(900, 400)];
    self.scrollView.delegate = self;
    if(self.viewImage)
        self.blurView.image = [self.viewImage stackBlur:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setBlurView:nil];
    [super viewDidUnload];
}

-(IBAction)dismissPressed:(id)sender
{
    [[SettingModal instance] finishTourialWithProgress:self.pageControl.numberOfPages];
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int x = self.scrollView.contentOffset.x;
    
    if (x < 0) {
        [self.pageControl setCurrentPage:0];
    }
    else if (0 < x && x < 0 + 300) {
        [self.pageControl setCurrentPage:1];
    }
    else if (0 + 300 < x && x < 0 + 600) {
        [self.pageControl setCurrentPage:2];
    }
}

@end
