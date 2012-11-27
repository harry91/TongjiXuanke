//
//  NewsDetailViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-10-15.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import "Category.h"

#import "GADBannerViewDelegate.h"

@class GADBannerView, GADRequest;

@interface NewsDetailViewController : UIViewController <UIWebViewDelegate,GADBannerViewDelegate>
{
    News *news;
    UISegmentedControl *segmentedControl;
    int textLoadComplete;
    GADBannerView *adBanner;
    UIImageView *adPlaceHolder;
    UIButton *fav_button;
}
@property (weak, nonatomic) IBOutlet UIWebView *original_webview;
@property (weak, nonatomic) IBOutlet UIWebView *puretext_webview;

@property (strong,nonatomic) NSURL *baseURL;

- (void)configureWithNews:(News *)news;

@end
