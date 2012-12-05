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
#import "NSNotificationCenter+Xuanke.h"
#import "ReachabilityChecker.h"

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
                                 CGSizeFromGADAdSize(kGADAdSizeBanner).height - 41);
    
    if([[ReachabilityChecker instance] hasInternetAccess])
    {
        // Use predefined GADAdSize constants to define the GADBannerView.
        adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner
                                                  origin:origin];
        adBanner.adUnitID = @"a150b23cf74437a";
        adBanner.delegate = self;
        [adBanner setRootViewController:self];
        [self.view addSubview:adBanner];
        adBanner.center = CGPointMake(self.view.center.x, adBanner.center.y);
        GADRequest *request = [GADRequest request];
        [request addKeyword:@"同济"];
        [request addKeyword:@"大学生"];
        [request addKeyword:@"研究生"];
        [request addKeyword:@"英语"];
        [request addKeyword:@"微软"];
        [request addKeyword:@"苹果"];
        [request addKeyword:@"土木"];
        [request addKeyword:@"手机"];
        [request addKeyword:@"新东方"];
        [request addKeyword:@"上海"];
        [request addKeyword:@"嘉年华"];
        [request addKeyword:@"游戏"];
        [request addKeyword:@"学习"];
        [request addKeyword:@"单词"];
        [request addKeyword:@"出国"];
        [request addKeyword:news.title];
        // Make the request for a test ad. Put in an identifier for the simulator as
        // well as any devices you want to receive test ads.
        request.testDevices =
        [NSArray arrayWithObjects:
         nil];
        [adBanner loadRequest:request];
    }
    else
    {
        adPlaceHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"adPlaceHolder.png"]];
        CGRect frame = adPlaceHolder.frame;
        frame.origin = origin;
        adPlaceHolder.frame = frame;
        [self.view addSubview:adPlaceHolder];
    }
}

- (void)removeAds:(NSNotification*)notification
{
    NSNumber* r = notification.object;
    if(![r boolValue])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级失败"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [adBanner removeFromSuperview];
    adBanner = nil;
    
    CGRect frame = self.original_webview.frame;
    frame.size.height += 50;
    self.original_webview.frame = frame;
    self.puretext_webview.frame = frame;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [UIView animateWithDuration:0.2 animations:^(){
        CGRect frame = fav_button.frame;
        frame.origin.y = -70;
        
        fav_button.frame = frame;
} completion:^(BOOL finish){
        [fav_button removeFromSuperview];}
     ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.original_webview.delegate = self;
    self.puretext_webview.delegate = self;
    
    NSString* articleViewString = news.content;
    NSString* webViewString = articleViewString;
    if([[SettingModal instance] isCategoryAtIndexServerRSS:[[SettingModal instance] indexOfCategoryWithName:news.category.name]])
    {
        {
            NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"newsdetailArticleView" ofType:@"html"];
            NSString *infoText = [[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
            articleViewString = [infoText stringByReplacingOccurrencesOfString:@"@#Content#@" withString:articleViewString];
        }
        {
            NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"newsdetailWebView" ofType:@"html"];
            NSString *infoText = [[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
            webViewString = [infoText stringByReplacingOccurrencesOfString:@"@#Content#@" withString:articleViewString];
        }
    }
    
    NSLog(@"Detail news String: %@",articleViewString);
    
    [self.original_webview loadHTMLString:webViewString baseURL:self.baseURL];
    [self.puretext_webview loadHTMLString:articleViewString baseURL:self.baseURL];
    
    news.haveread = [[NSNumber alloc] initWithBool:YES];
    [[MyDataStorage instance] saveContext];
    [self configureNavBar];
    [self configureAds];
    
    [NSNotificationCenter registerUpgradeProNotificationWithSelector:@selector(removeAds:) target:self];
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
        [UIView animateWithDuration:0.2 animations:^(){
            CGRect frame = fav_button.frame;
            frame.origin.y = -2;
            
            fav_button.frame = frame;
            }
                         completion:^(BOOL finish){
                             [UIView animateWithDuration:0.1 animations:^(){
                                 CGRect frame = fav_button.frame;
                                 frame.origin.y = -4;
                                 
                                 fav_button.frame = frame;
                             }];
                         }];
    }
    else if(!favorated)
    {
        [UIView animateWithDuration:0.2 animations:^(){
            CGRect frame = fav_button.frame;
            frame.origin.y = - 25;
            
            fav_button.frame = frame;
        }];
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
    
    CGRect frame;
    frame.origin.x = 260;
    frame.origin.y = -30;
    
    frame.size.width = 35;
    frame.size.height = 63;
    
    fav_button = [[UIButton alloc] initWithFrame:frame];
    [fav_button setImage:[UIImage imageNamed:@"fav_ribbon.png"] forState:UIControlStateNormal];
    [fav_button setImage:[UIImage imageNamed:@"fav_ribbon.png"] forState:UIControlStateHighlighted];
    [fav_button addTarget:self action:@selector(clickFavButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar addSubview:fav_button];
    
    BOOL favorated = [news.favorated boolValue];
    [self matchFavoratebuttonApperaence:favorated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
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
