//
//  CAUPNewsModel.m
//  TongjiXuanke
//
//  Created by Song on 12-12-6.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "CAUPNewsModel.h"
#import "DataOperator.h"

@implementation CAUPNewsModel

-(id)init
{
    if(self = [super init])
    {
        serverCategory = @"建筑与城市规划";
    }
    return self;
}

-(NSString*)safariLink:(News*)aNews
{
    return [@"http://old.tongji-caup.org/student/news_detail.asp?id=" stringByAppendingString:aNews.url];
}


@end
