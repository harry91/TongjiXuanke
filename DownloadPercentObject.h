//
//  UIDownloadBar.h
//  UIDownloadBar
//
//  Created by SAKrisT on 7/8/10.
//  Copyright 2010 www.developers-life.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DownloadPercentDelegate;

@interface DownloadPercentObject : NSObject {
	NSURLRequest		*DownloadRequest;
	NSURLConnection		*DownloadConnection;
	NSMutableData		*receivedData;
	NSString			*localFilename;
	NSURL				*downloadUrl;
	id<DownloadPercentDelegate> delegate;
	float				bytesReceived;
	long long			expectedBytes;
	
	BOOL				operationFinished, operationFailed, operationBreaked;
	BOOL				operationIsOK;	
	BOOL				appendIfExist;
	FILE				*downFile;
	//NSString			*fileUrlPath;
	NSString			*possibleFilename;
	
	
	float percentComplete;
}

- (DownloadPercentObject *)initWithURL:(NSURL *)fileURL timeout:(NSInteger)timeout delegate:(id<DownloadPercentDelegate>)theDelegate;

@property (assign) BOOL operationIsOK;
@property (assign) BOOL appendIfExist;

@property (nonatomic, readonly) NSMutableData* receivedData;
@property (nonatomic, readonly, retain) NSURLRequest* DownloadRequest;
@property (nonatomic, readonly, retain) NSURLConnection* DownloadConnection;
@property (nonatomic, assign) id<DownloadPercentDelegate> delegate;

@property (nonatomic, readonly) float percentComplete;
@property (nonatomic, retain) NSString *possibleFilename;

- (void) forceStop;

- (void) forceContinue;

@end


@protocol DownloadPercentDelegate<NSObject>

@optional
- (void)downloadObject:(DownloadPercentObject *)downloadBar didFinishWithData:(NSData *)fileData suggestedFilename:(NSString *)filename;
- (void)downloadObject:(DownloadPercentObject *)downloadBar didFailWithError:(NSError *)error;
- (void)downloadObjectUpdated:(DownloadPercentObject *)downloadBar;

@end
