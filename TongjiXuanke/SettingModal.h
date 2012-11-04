//
//  SettingModal.h
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModal : NSObject

+(SettingModal*)instance;

-(BOOL)shouldDownloadAllContentWithoutWIFI;
-(void)setShouldDownloadAllContentWithoutWIFI:(BOOL)value;

-(int)autoCleanInterval;
-(void)setAutoCleanInterval:(int)value;
@end
