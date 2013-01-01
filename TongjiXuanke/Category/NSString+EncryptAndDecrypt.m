//
//  NSString+EncryptAndDecrypt.m
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "NSString+EncryptAndDecrypt.h"

#import "AESCrypt.h"

@implementation NSString (EncryptAndDecrypt)


NSString *password = @"snow";

+(NSString*)stringByEncryptString:(NSString*)str
{
    return [AESCrypt encrypt:str password:password];;
}

+(NSString*)stringByDecryptString:(NSString*)str
{
    return [AESCrypt decrypt:str password:password];;
}


@end
