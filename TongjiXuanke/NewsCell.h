//
//  NewsCell.h
//  TongjiXuanke
//
//  Created by Song on 12-10-14.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *briefContent;
@property (weak, nonatomic) IBOutlet UIImageView *unreadIndicator;
@property (weak, nonatomic) IBOutlet UILabel *catagory;
@property (weak, nonatomic) IBOutlet UILabel *dateandtime;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@end
