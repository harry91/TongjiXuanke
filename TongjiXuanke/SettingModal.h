//
//  SettingModal.h
//  TongjiXuanke
//
//  Created by Song on 12-10-19.
//  Copyright (c) 2012年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModal : NSObject
{
    NSArray *categorys;
    NSMutableArray *subscribledIndex;
}

+(SettingModal*)instance;

-(BOOL)shouldDownloadAllContentWithoutWIFI;
-(void)setShouldDownloadAllContentWithoutWIFI:(BOOL)value;

-(int)autoCleanInterval;
-(void)setAutoCleanInterval:(int)value;

-(int)numberOfCategory;
-(NSString*) nameForCategoryAtIndex:(int)index;
-(NSString*) classStringForCategoryAtIndex:(int)index;
-(NSString*) baseURLStringForCategoryAtIndex:(int)index;
-(BOOL) isCategoryAtIndexServerRSS:(int)index;
-(int)indexOfCategoryWithName:(NSString*)str;
-(int)serverIDForCategoryAtIndex:(int)index;

-(BOOL)hasSubscribleCategoryAtIndex:(int)index;
-(BOOL)setSubscribleCategoryAtIndex:(int)index to:(BOOL)value;
-(int)subscribledCount;


-(int)needHelp;//return the starting help page -1 for no
-(void)finishTourialWithProgress:(int)progress;


-(BOOL)hasStudentProfileSet;

-(NSString*)studentName;
-(NSString*)studentDepartment;
-(NSString*)studentMajor;
-(NSString*)studentID;
-(NSString*)password;

-(void)doLogoutCleanUp;

@property (nonatomic,strong) NSString* currentCategory;
@property (nonatomic,strong) NSString* currentHeader;

@property (nonatomic,retain) NSString* studentName;
@property (nonatomic,retain) NSString* studentDepartment;
@property (nonatomic,retain) NSString* studentMajor;
@property (nonatomic,retain) NSString* studentID;
@property (nonatomic,retain) NSString* password;

@end
