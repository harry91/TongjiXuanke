//
//  LogInModal.h
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsLoaderProtocal.h"

@interface LogInModal : NSObject<UIWebViewDelegate>
{
    UIWebView *_webView;
    int loginInState;
    NSString *_content;
    NSMutableArray *dict;
    int tryTime;
    BOOL finished;
}
@property (nonatomic) id<NewsLoaderProtocal> delegate;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* password;

-(void)start;

@end
