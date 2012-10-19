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

@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController


- (void)configureWithNews:(News *)aNews {
    news = aNews;
    textLoadComplete = 0;
}

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
    self.dateLabel.text = [NSString strTimeAgoFromDate:news.date];
    self.titleLabel.text = news.title;
    self.categoryLabel.text = news.category.name;
    
    
    NSLog(@"content: %@",news.content);
    
    self.original_webview.delegate = self;
    self.puretext_webview.delegate = self;
    
    NSString* newsString = news.content;
    
    [self.original_webview loadHTMLString:newsString baseURL:[NSURL URLWithString:@"http://xuanke.tongji.edu.cn/"]];
    
    
    news.haveread = [[NSNumber alloc] initWithBool:YES];
    [[MyDataStorage instance] saveContext];
    [self configureNavBar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(webView == self.original_webview)
    {
        if(textLoadComplete != 0)
            return;
        NSString *infoSouceFile = [[NSBundle mainBundle] pathForResource:@"newsdetail" ofType:@"html"];
        NSString *infoText = [[NSString alloc] initWithContentsOfFile:infoSouceFile encoding:NSUTF8StringEncoding error:nil];
        NSString *s = [self.original_webview stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText;"];
        s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        s = [s stringByReplacingOccurrencesOfString:news.title withString:@""];
        
        while([s rangeOfString:@"<br><br>"].length >= 1)
        {
            s = [s stringByReplacingOccurrencesOfString:@"<br><br>" withString:@"<br>"];
        }
        
        infoText = [infoText stringByReplacingOccurrencesOfString:@"@#Content#@" withString:s];
        NSLog(@"info text:%@", infoText);
        [self.puretext_webview loadHTMLString:infoText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
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

- (void)clickFavButton
{
    news.favorated = [NSNumber numberWithBool:YES];
    [[MyDataStorage instance] saveContext];
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
    
    
    UIBarButtonItem *favButton = [UIBarButtonItem getFunctionButtonItemWithTitle:@"收藏" target:self action:@selector(clickFavButton)];
    self.navigationItem.rightBarButtonItem = favButton;
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDateLabel:nil];
    [self setTitleLabel:nil];
    [self setCategoryLabel:nil];
    [self setOriginal_webview:nil];
    [self setPuretext_webview:nil];
    [super viewDidUnload];
}

@end
