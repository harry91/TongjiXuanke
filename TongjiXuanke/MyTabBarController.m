//
//  MyTabBarController.m
//  TongjiXuanke
//
//  Created by Song on 12-10-14.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

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
    
    UITabBar *tabBar = self.tabBar;
    
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
    {
        // set it just for this instance
        //[tabBar setBackgroundImage:[UIImage imageNamed:@"tabbarBG.png"]];
        
        // set for all
        [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbarBG.png"]];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"selectedIndicator.png"]];
        
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithWhite:0.5 alpha:1], UITextAttributeTextColor,
                                                           [UIColor blackColor], UITextAttributeTextShadowColor, nil]
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithWhite:0.85 alpha:1], UITextAttributeTextColor,
                                                           [UIColor blackColor], UITextAttributeTextShadowColor, nil]
                                                 forState:UIControlStateSelected];
    }
    
    UIImage *selectedImage0 = [UIImage imageNamed:@"item0_selected.png"];
    UIImage *unselectedImage0 = [UIImage imageNamed:@"item0_unselected.png"];
    
    UIImage *selectedImage1 = [UIImage imageNamed:@"item1_selected.png"];
    UIImage *unselectedImage1 = [UIImage imageNamed:@"item1_unselected.png.png"];
    
    UIImage *selectedImage2 = [UIImage imageNamed:@"item2_selected.png"];
    UIImage *unselectedImage2 = [UIImage imageNamed:@"item2_unselected.png"];
    
    
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
    [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
    

    
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
