//
//  SideViewController.m
//  TongjiXuanke
//
//  Created by Song on 12-11-7.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "SideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ColorImage.h"
#import "SettingTableViewController.h"
#import "SettingModal.h"
#import "NSNotificationCenter+Xuanke.h"

@interface SideViewController ()

@end

@implementation SideViewController

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
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    UIImage *resizeableImage = [[UIImage imageNamed:@"sideBarBGTextile.png"] resizableImageWithCapInsets:inset];
    self.background.image = resizeableImage;
    
    [NSNotificationCenter registerCategoryChangedNotificationWithSelector:@selector(categoryChanged) target:self];
    
    NSArray *headers = @[
    //@"设置",
    @"列表",
    @"收藏",
	];
    self.headers = headers;
    [self generateCellInfo];
    
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    //[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    [self.tableView setScrollsToTop:NO];
}


- (void)categoryChanged
{
    [self generateCellInfo];
    [self.tableView reloadData];
}

- (void)generateCellInfo
{
    UIImage *clearImage = [UIImage imageWithColor:[UIColor clearColor]];
    NSMutableArray *categorys = [@[@{@"image": clearImage, @"text": NSLocalizedString(@"全部", @"")}] mutableCopy];
    
    for(int i = 0; i < [[SettingModal instance] numberOfCategory]; i++)
    {
        if([[SettingModal instance] hasSubscribleCategoryAtIndex:i])
        {
            NSMutableDictionary *category = [@{} mutableCopy];
            category[@"image"] = clearImage;
            category[@"text"] = [[SettingModal instance] nameForCategoryAtIndex:i];
            [categorys addObject:category];
        }
    }
    NSArray *cellInfos = [NSArray arrayWithObjects:categorys, categorys,nil];
    self.cellInfos = cellInfos;
}



- (void)viewWillAppear:(BOOL)animated
{
    if([[SettingModal instance] hasStudentProfileSet])
    {
        self.usernameLabel.text = [[SettingModal instance] studentName];
    }
    else
    {
        self.usernameLabel.text = [[SettingModal instance] studentID];
    }
}


-(IBAction)settingClicked:(id)sender
{
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        SettingTableViewController* mainView = [self.storyboard instantiateViewControllerWithIdentifier:@"settingView"];
        controller.centerController = mainView;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        }
//        [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
    ];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackground:nil];
    [self setTableView:nil];
    [self setUsernameLabel:nil];
    [super viewDidUnload];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"sections: %d",self.headers.count);
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"count: %d",((NSArray *)_cellInfos[section]).count);
    return ((NSArray *)_cellInfos[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHMenuCell";
    GHMenuCell *cell = (GHMenuCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = self.cellInfos[indexPath.section][indexPath.row];
	cell.textLabel.text = info[@"text"];
	cell.imageView.image = info[@"image"];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (self.headers[section] == [NSNull null]) ? 0.0f : 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = _headers[section];
	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 21.0f)];
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = @[
        (id)[UIColor colorWithRed:(67.0f/255.0f) green:(70.0f/255.0f) blue:(76.0f/255.0f) alpha:1.0f].CGColor,
        (id)[UIColor colorWithRed:(66.0f/255.0f) green:(62.0f/255.0f) blue:(71.0f/255.0f) alpha:1.0f].CGColor,
		];
		[headerView.layer insertSublayer:gradient atIndex:0];
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 12.0f, 5.0f)];
		textLabel.text = (NSString *) headerText;
		textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 1.0f)];
		textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		textLabel.textColor = [UIColor colorWithRed:(145.0f/255.0f) green:(149.0f/255.0f) blue:(166.0f/255.0f) alpha:1.0f];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(78.0f/255.0f) green:(86.0f/255.0f) blue:(103.0f/255.0f) alpha:1.0f];
		[headerView addSubview:topLine];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(36.0f/255.0f) green:(42.0f/255.0f) blue:(5.0f/255.0f) alpha:1.0f];
		[headerView addSubview:bottomLine];
	}
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];

    [SettingModal instance].currentCategory = self.cellInfos[indexPath.section][indexPath.row][@"text"];
    [SettingModal instance].currentHeader = self.headers[indexPath.section];
    
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newsView"];
        self.viewDeckController.centerController = vc;
    }
     ];
}


@end
