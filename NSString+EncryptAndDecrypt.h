//
//  NSString+EncryptAndDecrypt.h
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EncryptAndDecrypt)

+(NSString*)stringByEncryptString:(NSString*)str;

+(NSString*)stringByDecryptString:(NSString*)str;


@end
