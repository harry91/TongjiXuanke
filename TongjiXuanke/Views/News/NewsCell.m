//
//  NewsCell.m
//  TongjiXuanke
//
//  Created by Song on 12-10-14.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    //[self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:nil];

    // Configure the view for the selected state
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing)
    {
        [UIView animateWithDuration:0.25 animations:^(){
            self.favIndicator.alpha = 0;
            self.unreadIndicator.alpha = 0;
            self.cellAccessory.alpha = 0;
            
            CGRect frame;
            frame = self.title.frame;
            frame.origin.x = 38;
            self.title.frame = frame;
            
            frame = self.briefContent.frame;
            frame.origin.x = 38;
            self.briefContent.frame = frame;
            
            frame = self.catagory.frame;
            frame.origin.x = 38;
            self.catagory.frame = frame;
            
            self.checkState.alpha = 1;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^(){
            self.favIndicator.alpha = 1.0;
            self.unreadIndicator.alpha = 1.0;
            self.cellAccessory.alpha = 1.0;
            
            CGRect frame;
            frame = self.title.frame;
            frame.origin.x = 23;
            self.title.frame = frame;
            
            frame = self.briefContent.frame;
            frame.origin.x = 23;
            self.briefContent.frame = frame;
            
            frame = self.catagory.frame;
            frame.origin.x = 23;
            self.catagory.frame = frame;

            self.checkState.alpha = 0;
            self.checkState.highlighted = NO;
        }];
    }
}

- (void)setChecked:(BOOL)value
{
    self.checkState.highlighted = value;
}

@end
