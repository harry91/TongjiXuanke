//
//  MyIAP.m
//  TongjiXuanke
//
//  Created by Song on 12-11-25.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "MyIAP.h"
#import "SettingModal.h"
#import "NSNotificationCenter+Xuanke.h"

#define GOPROID @"com.sbhhbs.tzzzd.pro"

@implementation MyIAP


MyIAP* _MYIAP_INSTANCE = nil;


- (id)init
{
    if(self = [super init])
    {
        [IAPManager shareInstance].delegate = self;
    }
    return self;
}

+ (MyIAP*) instance
{
    if(!_MYIAP_INSTANCE)
    {
        _MYIAP_INSTANCE = [[MyIAP alloc] init];
    }
    return _MYIAP_INSTANCE;
}

- (void)buyPro
{
    [[IAPManager shareInstance] buyIAPProductWithIndetifier:GOPROID];
}

- (void)goPro
{
    [NSNotificationCenter postUpgradeProNotificationWithSuccess:YES];
    [[SettingModal instance] goPro];
}

- (void)restorePurchase
{
    [[IAPManager shareInstance] restoreBatchTransactions];
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"IAP completeTransaction");
    if([transaction.transactionIdentifier isEqualToString:GOPROID])
    {
        [self goPro];
        return;
    }
    [NSNotificationCenter postUpgradeProNotificationWithSuccess:NO];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"IAP failedTransaction");
    [NSNotificationCenter postUpgradeProNotificationWithSuccess:NO];
}


- (void)cancelTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"IAP cancelTransaction");
    [NSNotificationCenter postUpgradeProNotificationWithSuccess:NO];
}

- (void)restoreBatchTransactions:(NSArray *)transactions
{
    NSLog(@"IAP restoreBatchTransactions");
    for(NSString *identifier in transactions)
    {
        if([identifier isEqualToString:GOPROID])
        {
            [self goPro];
            return;
        }
    }
    [NSNotificationCenter postUpgradeProNotificationWithSuccess:NO];
}

- (void)downloadIAPDataFailed
{
    NSLog(@"IAP download iap data failed");
    [NSNotificationCenter postUpgradeProNotificationWithSuccess:NO];
}

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (VerifyReceiptResult)verifyReceipt:(SKPaymentTransaction *)transaction
{
    NSString *jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
    NSString *completeString = [NSString stringWithFormat:@"http://sbhhbs.com/IAP/verify.php?data=%@", jsonObjectString];
    NSURL *urlForValidation = [NSURL URLWithString:completeString];
    NSLog(@"Verify URL:%@",completeString);
    NSMutableURLRequest *validationRequest = [[NSMutableURLRequest alloc] initWithURL:urlForValidation];
    [validationRequest setHTTPMethod:@"GET"];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:validationRequest returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
    NSLog(@"respond: %@",responseString);
    if ([responseString rangeOfString:@"success"].location == NSNotFound) {
        return VerifyReceiptResult_FAILED;
    }
    return VerifyReceiptResult_SUCCESS;
}


@end
