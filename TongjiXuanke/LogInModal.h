//
//  LogInModal.h
//  TongjiXuanke
//
//  Created by Song on 12-11-3.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsLoaderProtocal.h"
#import "StudentProfileGetter.h"

@protocol LoginProtocal <NSObject>

-(void)LoginSuccess;
-(void)LoginFailWithError:(NSError*)error;

@end


@interface LogInModal : NSObject<UIWebViewDelegate>
{
    UIWebView *_webView;
    int loginInState;
    NSString *_content;
    NSMutableArray *dict;
    int tryTime;
    BOOL finished;
    StudentProfileGetter *studentProfileGetter;
}
@property (nonatomic) id delegate;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* password;

-(void)start;

@end
