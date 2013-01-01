//
//  HelpViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-11-28.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIImageView *blurView;
@property (nonatomic,retain) UIImage *viewImage;
@property (nonatomic) int shouldShowPage;
-(IBAction)dismissPressed:(id)sender;

@end
