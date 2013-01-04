//
//  GHSidebarMenuCell.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>
#import "LKBadgeView.h"

@interface GHMenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LKBadgeView *countBadge;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end
