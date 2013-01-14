//
//  ParseNewsModel.h
//  TongjiXuanke
//
//  Created by Song on 13-1-13.
//  Copyright (c) 2013年 Song. All rights reserved.
//

#import "DummyNewsModel.h"
#import "NewsFeedProtocal.h"

@interface ParseNewsModel : DummyNewsModel<NewsFeedProtocal>
{
    NSMutableArray *dict;
    BOOL isgetting;
    NSString *curl;
    NSMutableArray *urlToRetireve;
    NSString *serverCategory;
    __block NSString* parseTextContent;
    
    NSString* briefContentToSave;
    int queryLimit;
}
-(void)finishRetrievingDataForUrl:(NSString*)url;

@end
