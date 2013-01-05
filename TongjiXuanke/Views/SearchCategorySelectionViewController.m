//
//  SearchCategorySelectionViewController.m
//  TongjiXuanke
//
//  Created by Song on 13-1-1.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "SearchCategorySelectionViewController.h"
#import "SettingModal.h"

@implementation SearchCategorySelectionViewController

- (void)viewDidLoad
{
    NSArray *headers = @[
    @"列表",
    @"收藏",
	];
    self.headers = headers;
    [self generateCellInfo];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    currentIndexPath = indexPath;
    self.currentCategory = self.cellInfos[indexPath.section][indexPath.row][@"text"];
    self.currentHeader = self.headers[indexPath.section];
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}


- (void)generateCellInfo
{
    NSMutableArray *categorys = [@[@{@"text": NSLocalizedString(@"全部", @"")}] mutableCopy];
    
    for(int i = 0; i < [[SettingModal instance] numberOfCategory]; i++)
    {
        if([[SettingModal instance] hasSubscribleCategoryAtIndex:i])
        {
            NSMutableDictionary *category = [@{} mutableCopy];
            category[@"text"] = [[SettingModal instance] nameForCategoryAtIndex:i];
            [categorys addObject:category];
        }
    }
    NSArray *cellInfos = [NSArray arrayWithObjects:categorys, categorys,nil];
    self.cellInfos = cellInfos;
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
    static NSString *CellIdentifier = @"searchCategoryCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = self.cellInfos[indexPath.section][indexPath.row];
    UILabel *textLabel = (UILabel*) [cell viewWithTag:1];
    textLabel.text = info[@"text"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(indexPath.section == currentIndexPath.section && indexPath.row == currentIndexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
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
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 27.0f)];
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 0.0f, 6.0f)];
		textLabel.text = (NSString *) headerText;
		textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 1.0f)];
		textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		textLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
		textLabel.textColor = [UIColor colorWithRed:(145.0f/255.0f) green:(149.0f/255.0f) blue:(166.0f/255.0f) alpha:1.0f];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(36.0f/255.0f) green:(42.0f/255.0f) blue:(5.0f/255.0f) alpha:0.5f];
		[headerView addSubview:bottomLine];
	}
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.currentCategory = self.cellInfos[indexPath.section][indexPath.row][@"text"];
    self.currentHeader = self.headers[indexPath.section];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:currentIndexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    currentIndexPath = indexPath;
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.delegate categoryDidChangeWithHeader:self.currentHeader andCategory:self.currentCategory];
}


@end
