//
//  NewsInfoViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-12-31.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NewsInfoViewController.h"
#import "NSString+TimeConvertion.h"
#import "SettingModal.h"
#import "Brain.h"

@implementation NewsInfoViewController


- (void)viewDidLoad
{
    self.scrollView.contentSize = CGSizeMake(320, 260);
    self.departmentLabel.text = news.category.name;
    self.timeLabel.text = [NSString stringByConvertingTimeToAgoFormatFromDate:news.date];    self.titleLabel.text = news.title;
    
    
    NSString *categoryTitle = news.category.name;
    
    int categoryIndex = [[SettingModal instance] indexOfCategoryWithName:categoryTitle];
    id<NewsFeedProtocal> feed = [[Brain instance] instanceOfCategoryAtIndex:categoryIndex];
    self.url = [feed safariLink:news];
    if(!self.url)
    {
        [self.openInSafariBtn setHidden:YES];
        [self.copylinkBtn setHidden:YES];
    }
    NSLog(@"safari url: %@",self.url);
    
    if ([news.category.name isEqualToString:@"选课网"]) {
        [self.reloginNotifierLabel setHidden:NO];
    }
    else
    {
        [self.reloginNotifierLabel setHidden:YES];
    }
    
    [self.doneBtn addTarget:self.myparent action:@selector(dismissMySemiModalView) forControlEvents:UIControlEventTouchUpInside];
    [self.copylinkBtn addTarget:self.myparent action:@selector(semiModalViewCopyLink) forControlEvents:UIControlEventTouchUpInside];
    [self.openInSafariBtn addTarget:self.myparent action:@selector(semiModalViewOpenInSafari) forControlEvents:UIControlEventTouchUpInside];
    
    
    if(self.url)
    {
        UIImage *btnBG = [[UIImage imageNamed:@"nav_bar_btn_finish.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        UIImage *btnBG_hl = [[UIImage imageNamed:@"nav_bar_btn_finish_hl.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [self.copylinkBtn setBackgroundImage:btnBG forState:UIControlStateNormal];
        [self.copylinkBtn setBackgroundImage:btnBG_hl forState:UIControlStateHighlighted];
        
        [self.openInSafariBtn setBackgroundImage:btnBG forState:UIControlStateNormal];
        [self.openInSafariBtn setBackgroundImage:btnBG_hl forState:UIControlStateHighlighted];
    }
}

- (void)configureWithNews:(News *)aNews {
    news = aNews;
}


- (void)viewDidUnload {
    [self setBackground:nil];
    [self setTimeLabel:nil];
    [self setTitleLabel:nil];
    [self setDepartmentLabel:nil];
    [self setScrollView:nil];
    [self setDoneBtn:nil];
    [self setReloginNotifierLabel:nil];
    [self setCopylinkBtn:nil];
    [self setOpenInSafariBtn:nil];
    [super viewDidUnload];
}
@end
