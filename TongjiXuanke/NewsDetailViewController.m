//
//  NewsDetailViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-10-15.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "NSString+TimeConvertion.h"
#import "UILabel+Addition.h"
#import "UIBarButtonItem+Addtion.h"
#import "MyDataStorage.h"
#import "UIBarButtonItem+Addtion.h"
#import "SettingModal.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "MyIAP.h"

@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController


- (void)configureWithNews:(News *)aNews {
    news = aNews;
    textLoadComplete = 0;
    
    NSString *categoryTitle = news.category.name;
    
    int categoryIndex = [[SettingModal instance] indexOfCategoryWithName:categoryTitle];
    
    self.baseURL = [NSURL URLWithString:[[SettingModal instance] baseURLStringForCategoryAtIndex:categoryIndex]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)configureAds
{
    if([SettingModal instance].isProVersion)
        return;
    CGRect frame = self.original_webview.frame;
    frame.size.height -= 50;
    self.original_webview.frame = frame;
    self.puretext_webview.frame = frame;
    
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height -
                                 CGSizeFromGADAdSize(kGADAdSizeBanner).height - 40);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner
                                              origin:origin];
    adBanner.adUnitID = @"a150b23cf74437a";
    adBanner.delegate = self;
    [adBanner setRootViewController:self];
    [self.view addSubview:adBanner];
    adBanner.center = CGPointMake(self.view.center.x, adBanner.center.y);
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as
    // well as any devices you want to receive test ads.
    request.testDevices =
    [NSArray arrayWithObjects:
     nil];
    [adBanner loadRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.original_webview.delegate = self;
    self.puretext_webview.delegate = self;
    
    NSString* newsString = news.content;
    
    [self.original_webview loadHTMLString:newsString baseURL:self.baseURL];
    [self.puretext_webview loadHTMLString:newsString baseURL:self.baseURL];
    
    news.haveread = [[NSNumber alloc] initWithBool:YES];
    [[MyDataStorage instance] saveContext];
    [self configureNavBar];
    [self configureAds];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(webView == self.original_webview)
    {
        if(textLoadComplete != 0)
            return;
//        NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"newsdetail" ofType:@"html"];
//        NSString *infoText = [[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
//        NSString *s = [self.original_webview stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText;"];
//        s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
//        s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//        s = [s stringByReplacingOccurrencesOfString:news.title withString:@""];
//        
//        while([s rangeOfString:@"<br><br>"].length >= 1)
//        {
//            s = [s stringByReplacingOccurrencesOfString:@"<br><br>" withString:@"<br>"];
//        }
//        
//        infoText = [infoText stringByReplacingOccurrencesOfString:@"@#Content#@" withString:s];
//        NSLog(@"info text:%@", infoText);
//        [self.puretext_webview loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
        
        
        
        
        
//       NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]];
//        NSString *text = @"javascript:(function()%7BreadStyle='style-newspaper';readSize='size-large';readMargin='margin-wide';_readability_script=document.createElement('SCRIPT');_readability_script.type='text/javascript';_readability_script.src='MYPATHreadability.js?x='+(Math.random());document.getElementsByTagName('head')%5B0%5D.appendChild(_readability_script);_readability_css=document.createElement('LINK');_readability_css.rel='stylesheet';_readability_css.href='MYPATHreadability.css';_readability_css.type='text/css';_readability_css.media='screen';document.getElementsByTagName('head')%5B0%5D.appendChild(_readability_css);_readability_print_css=document.createElement('LINK');_readability_print_css.rel='stylesheet';_readability_print_css.href='MYPATHreadability-print.css';_readability_print_css.media='print';_readability_print_css.type='text/css';document.getElementsByTagName('head')%5B0%5D.appendChild(_readability_print_css);%7D)();";
//        text = [text stringByReplacingOccurrencesOfString:@"MYPATH" withString:url.description];
//        NSLog(@"text:%@",text);
//        
//        [self.original_webview stringByEvaluatingJavaScriptFromString:text];
//        
        
        textLoadComplete = 1;
    }
}

- (void)modeChanged:(id)sender
{
    if (segmentedControl.selectedSegmentIndex == 0) {
        //write here your action when first item selected
        self.original_webview.hidden = YES;
        self.puretext_webview.hidden = NO;
    } else {
        //write here your action when second item selected
        self.original_webview.hidden = NO;
        self.puretext_webview.hidden = YES;
    }
}

- (void)matchFavoratebuttonApperaence:(BOOL)favorated
{
    if(favorated)
    {
        [insideFavButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] forState:UIControlStateNormal];
        [insideFavButton setTitle:@"取消" forState:UIControlStateNormal];
        //[favButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] forState:UIControlStateHighlighted];
    }
    else if(!favorated)
    {
        [insideFavButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish.png"] forState:UIControlStateNormal];
        [insideFavButton setTitle:@"收藏" forState:UIControlStateNormal];
        //[favButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] forState:UIControlStateHighlighted];
    }
}

- (void)clickFavButton
{
    if([SettingModal instance].isProVersion)
    {
        BOOL favorated = [news.favorated boolValue];
        
        news.favorated = [NSNumber numberWithBool:!favorated];
        favorated =! favorated;
        [self matchFavoratebuttonApperaence:favorated];
        
        [[MyDataStorage instance] saveContext];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"专业版"
                                                       message:@"升级为专业版，开启收藏，去除广告并可免费使用以后所有更新内容。仅需￥6.00。"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"升级",nil];
        [alert show];
    }
}

//根据被点击按钮的索引处理点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"clickedButtonAtIndex:%d",buttonIndex);
    switch (buttonIndex) {
        case 1://upgrade
            [[MyIAP instance] buyPro];
            
            break;
            
        default:
            break;
    }
}

- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureNavBar {
    NSArray* arr = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"toolbar_article_view.png"], [UIImage   imageNamed:@"toolbar_web_view.png"], nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:arr];
    [segmentedControl addTarget:self action:@selector(modeChanged:)   forControlEvents:UIControlEventValueChanged];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    self.navigationItem.titleView = segmentedControl;
    [segmentedControl setSelectedSegmentIndex:0];
    [self modeChanged:nil];

    
    UIBarButtonItem *backButton = [UIBarButtonItem getBackButtonItemWithTitle:@"返回" target:self action:@selector(clickBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    insideFavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [insideFavButton setTitle:@"收藏" forState:UIControlStateNormal];
    [insideFavButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] forState:UIControlStateNormal];
    [insideFavButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8f] forState:UIControlStateHighlighted];
    [insideFavButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    insideFavButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    insideFavButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    [insideFavButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish.png"] forState:UIControlStateNormal];
    [insideFavButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] forState:UIControlStateHighlighted];
    
    [insideFavButton addTarget:self action:@selector(clickFavButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *favButton = [[UIBarButtonItem alloc] initWithCustomView:insideFavButton];

    self.navigationItem.rightBarButtonItem = favButton;
    
    BOOL favorated = [news.favorated boolValue];
    [self matchFavoratebuttonApperaence:favorated];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setOriginal_webview:nil];
    [self setPuretext_webview:nil];
    [super viewDidUnload];
}


#pragma mark GADBannerViewDelegate impl

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end
