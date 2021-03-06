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
#import "NSNotificationCenter+Xuanke.h"
#import "ReachabilityChecker.h"
#import "UIViewController+KNSemiModal.h"
#import "UINavigationBar+DropShadow.h"
#import "UIWebView+HighlightWebView.h"

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


- (void)configureContent
{
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.original_webview.delegate = self;
    self.puretext_webview.delegate = self;
    
    original_fav_state = [news.favorated boolValue];
    
    havereadChanged = NO;
    if(![news.haveread boolValue])
    {
        news.haveread = [[NSNumber alloc] initWithBool:YES];
        havereadChanged = YES;
    }
    [self configureNavBar];
    [self performSelector:@selector(configureContent) withObject:nil afterDelay:0.2];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(self.highlightText)
    {
        [webView highlightAllOccurencesOfString:self.highlightText];
    }
    else
    {
        int nameCount = 0;
        if([SettingModal instance].hasStudentProfileSet)
        {
            nameCount = [webView highlightAllOccurencesOfString:[SettingModal instance].studentName];
            if(nameCount == 0)
            {
                [webView highlightAllOccurencesOfString:[SettingModal instance].studentID];
            }
        }
        else
        {
            [webView highlightAllOccurencesOfString:[SettingModal instance].studentID];
        }
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
        [fav_button setImage:[UIImage imageNamed:@"fav_ribbon.png"] forState:UIControlStateNormal];
        [fav_button setImage:[UIImage imageNamed:@"fav_ribbon.png"] forState:UIControlStateHighlighted];
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
        [fav_button setImage:[UIImage imageNamed:@"fav_ribbon_add.png"] forState:UIControlStateNormal];
        [fav_button setImage:[UIImage imageNamed:@"fav_ribbon_add.png"] forState:UIControlStateHighlighted];
        [UIView animateWithDuration:0.2 animations:^(){
            CGRect frame = fav_button.frame;
            frame.origin.y = - 20;
            
            fav_button.frame = frame;
        }];
    }
}

- (void)clickFavButton
{
    BOOL favorated = [news.favorated boolValue];
    
    news.favorated = [NSNumber numberWithBool:!favorated];
    favorated =! favorated;
    [self matchFavoratebuttonApperaence:favorated];
}



- (void)clickBackButton
{
    if(havereadChanged)
    {
        [[SettingModal instance] decreaseUnreadCountInCategory:news.category.name];
    }
    if([news.favorated boolValue] != original_fav_state)
    {
        if(original_fav_state)//now NO
        {
            [[SettingModal instance] decreaseFavedCountInCategory:news.category.name];
        }
        else
            [[SettingModal instance] increaseFavedCountInCategory:news.category.name];
    }
    if([news.favorated boolValue] != original_fav_state || havereadChanged)
    {
        [[MyDataStorage instance] saveContext];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickInfoButton
{    
    newsInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"newsInfoView"];
    [newsInfo configureWithNews:news];
    newsInfo.myparent = self;
    
    [self presentSemiView:newsInfo.view];
}

- (void)configureNavBar {
    NSArray* arr = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"toolbar_article_view.png"], [UIImage   imageNamed:@"toolbar_web_view.png"], nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:arr];
    [segmentedControl addTarget:self action:@selector(modeChanged:)   forControlEvents:UIControlEventValueChanged];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    infoButton.frame = CGRectMake(95, 0, 50, 30);
    
    [infoButton addTarget:self action:@selector(clickInfoButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 130, 30)];
    [container addSubview:segmentedControl];
    [container addSubview:infoButton];
    
    self.navigationItem.titleView = container;
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
    [fav_button setImage:[UIImage imageNamed:@"fav_ribbon_add.png"] forState:UIControlStateNormal];
    [fav_button setImage:[UIImage imageNamed:@"fav_ribbon_add.png"] forState:UIControlStateHighlighted];
    [fav_button addTarget:self action:@selector(clickFavButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.clipsToBounds = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar addSubview:fav_button];
    BOOL favorated = [news.favorated boolValue];
    
    [self matchFavoratebuttonApperaence:favorated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar dropShadowWithOffset:CGSizeMake(0, 2) radius:0.2 color:[UIColor blackColor] opacity:0.7];
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


- (IBAction)swipedLeft:(id)sender
{
    [self clickBackButton];
}


#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}


#pragma mark -
#pragma mark File preview

- (NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return documentsDirectoryPath;
}

- (void)downloadComplete
{
    if(receivedData)
    {
        [self connectionDidFinishLoading:nil];
    }
    else
    {
        [self connection:nil didFailWithError:nil];
    }
}

-(void)startDownloadWithURL:(NSURL*)url
{
    receivedData = nil;
	receivedData = [NSData dataWithContentsOfURL:url];
    
    [self performSelectorOnMainThread:@selector(downloadComplete) withObject:nil waitUntilDone:NO];
}


-(BOOL)shouldDownloadFileType:(NSURL*)theRessourcesURL
{
    NSString *fileExtension = [theRessourcesURL pathExtension];
    
    if (([fileExtension compare:@"mp3" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"doc" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"docx" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"pdf" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"ppt" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"pptx" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"xls" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"xlsx" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"zip" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"7z" options:NSCaseInsensitiveSearch] ==  NSOrderedSame) ||
        ([fileExtension compare:@"rar" options:NSCaseInsensitiveSearch] ==  NSOrderedSame)
        ) {
        if(fileExtension)
            return YES;
        
    }
    
    return NO;
}

- (void)showQuickLookPrivew
{
    QLPreviewController *ql = [[QLPreviewController alloc] init];
    ql.dataSource = self;
    ql.delegate = self;
    ql.currentPreviewItemIndex = 0; //0 because of the assumption that there is only 1 file
    [self presentModalViewController:ql animated:YES];
}


-(void)showDownloadIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    // Set determinate mode
    HUD.mode = MBProgressHUDModeIndeterminate;
    
    HUD.labelText = @"下载中";

}


- (void)handleDownloadWithURL:(NSURL*)theRessourcesURL
{
    filename = [theRessourcesURL lastPathComponent];
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self pathToDownloadTo]];
    if(fileExists)
    {
        urlDownload = [NSURL fileURLWithPath:[self pathToDownloadTo]];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(showDownloadIndicator) withObject:nil waitUntilDone:NO];
        
        [self performSelectorInBackground:@selector(startDownloadWithURL:) withObject:theRessourcesURL ];
        
        shouldWaitingForDownload = YES;
        
        while(shouldWaitingForDownload)
        {
            sleep(1);
        }
    }
    
    if(urlDownload)
    {
        [self performSelectorOnMainThread:@selector(showQuickLookPrivew) withObject:nil waitUntilDone:NO];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *theRessourcesURL = [request URL];
        if ([self shouldDownloadFileType:theRessourcesURL]) {
            [self performSelectorInBackground:@selector(handleDownloadWithURL:) withObject:theRessourcesURL];
            return NO;
        }
        else
        {
            // File type not supported
        }
    }
    return YES;
}

#pragma mark -
#pragma mark QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return urlDownload;
}

#pragma mark -
#pragma mark NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	expectedLength = [response expectedContentLength];
	currentLength = 0;
	HUD.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	currentLength += [data length];
    [receivedData appendData:data];
    
	HUD.progress = currentLength / (float)expectedLength;
}

- (NSString*)pathToDownloadTo
{
    NSString *docPath = [self documentsDirectoryPath];
    // Combine the filename and the path to the documents dir into the full path
    NSString *pathToDownloadTo = [NSString stringWithFormat:@"%@/%@", docPath, filename];
    return pathToDownloadTo;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
	NSString *pathToDownloadTo = [self pathToDownloadTo];
    
    NSError *error = nil;
    // Write the contents of our tmp object into a file
    [receivedData writeToFile:pathToDownloadTo options:NSDataWritingAtomic error:&error];
    if (error != nil) {
        NSLog(@"Failed to save the file: %@", [error description]);
        urlDownload = nil;
    } else {
        urlDownload = [NSURL fileURLWithPath:pathToDownloadTo];
        
    }
    [HUD hide:YES];
    shouldWaitingForDownload = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [HUD removeFromSuperview];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"下载失败";
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
    urlDownload = nil;
    shouldWaitingForDownload = NO;
}

#pragma mark - - SemiModel

- (void)dismissMySemiModalView
{
    [self dismissSemiModalViewWithCompletion:nil];
}

- (void)semiModalViewCopyLink
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:newsInfo.url];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:newsInfo.view.window animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"已复制到剪贴板";
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}

- (void)semiModalViewOpenInSafari
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: newsInfo.url]];
}

@end
