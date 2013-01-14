//
//  XuankeModel.m
//  xuanke
//
//  Created by Song on 12-10-13.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import "XuankeModel.h"
#import "DataOperator.h"
#import "NSString+HTML.h"

@implementation XuankeModel

-(id)init
{
    if(self = [super init])
    {
        serverCategory = @"选课网";
        queryLimit = 500;
    }
    return self;
}


-(void)finishRetrievingDataForUrl:(NSString*)url
{
    if([parseTextContent isEqualToString:@""])
        return;
    
    News* news = [self newsForURL:url];
    
    parseTextContent = [parseTextContent stringByReplacingOccurrencesOfString:@"<link rel=\"stylesheet\" href=\"/tj_public/css/main.css\">" withString:@""];
    parseTextContent = [parseTextContent stringByReplacingOccurrencesOfString:@"<input type=\"button\" class=\"INPUT_button\" value=\"关闭\" onclick=\"window.close()\">" withString:@""];
    briefContentToSave = [parseTextContent stringByConvertingHTMLToPlainText];
    NSRange fromThisPosition = [briefContentToSave rangeOfString:@"document.form2.submit();"];
    briefContentToSave = [briefContentToSave substringFromIndex:fromThisPosition.location+fromThisPosition.length + 2];
    briefContentToSave  = [briefContentToSave stringByReplacingOccurrencesOfString:news.title withString:@""];
    NSRange start = [parseTextContent rangeOfString:@"<script>"];
    NSRange end = [parseTextContent rangeOfString:@"</script>"];
    NSString *script = [parseTextContent substringWithRange:NSMakeRange(start.location,end.location - start.location + end.length)];
    parseTextContent = [parseTextContent stringByReplacingOccurrencesOfString:script withString:@""];
    
    briefContentToSave =  [briefContentToSave stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    briefContentToSave =  [briefContentToSave stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    //briefContent =  [briefContent stringByReplacingOccurrencesOfString: news.title withString:@""];
    briefContentToSave =  [briefContentToSave stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [super finishRetrievingDataForUrl:url];
    briefContentToSave = nil;
}


-(NSString*)safariLink:(News*)aNews
{
    NSString *urlToGo = @"http://xuanke.tongji.edu.cn/tj_public/jsp/tongzhi.jsp?id='URL'";
    urlToGo = [urlToGo stringByReplacingOccurrencesOfString:@"URL" withString:aNews.url];
    
    return urlToGo;
}


@end
