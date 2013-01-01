//
//  NewsDetailViewController.h
//  TongjiXuanke
//
//  Created by Song on 12-10-15.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
//#import "Category.h"
#import <QuickLook/QuickLook.h>

#import "MBProgressHUD.h"
#import "NewsInfoViewController.h"

@class GADBannerView, GADRequest;

@interface NewsDetailViewController : UIViewController <QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate,UIWebViewDelegate>
{
    News *news;
    UISegmentedControl *segmentedControl;
    int textLoadComplete;
    UIButton *fav_button;
    
    NSURL *urlDownload;
    long long expectedLength;
	long long currentLength;
    NSMutableData *receivedData;
    NSString *filename;
    MBProgressHUD *HUD;
    BOOL shouldWaitingForDownload;
    
    NewsInfoViewController *newsInfo;
}
@property (weak, nonatomic) IBOutlet UIWebView *original_webview;
@property (weak, nonatomic) IBOutlet UIWebView *puretext_webview;

@property (strong,nonatomic) NSURL *baseURL;

- (void)configureWithNews:(News *)news;

- (IBAction)swipedLeft:(id)sender;

- (void)dismissMySemiModalView;
- (void)semiModalViewCopyLink;
- (void)semiModalViewOpenInSafari;


@end
