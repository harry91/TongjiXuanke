//
//  MyIAP.h
//  TongjiXuanke
//
//  Created by Song on 12-11-25.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPManager.h"

@interface MyIAP : NSObject<IAPManagerDelegate>

+ (MyIAP*) instance;

- (void)buyPro;

- (void)restorePurchase;

@end
