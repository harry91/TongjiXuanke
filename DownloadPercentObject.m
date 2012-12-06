//
//  UIDownloadBar.m
//  UIDownloadBar
//
//  Created by SAKrisT on 7/8/10.
//  Copyright 2010 www.developers-life.com. All rights reserved.
//

#import "DownloadPercentObject.h"


@implementation DownloadPercentObject

@synthesize DownloadRequest,
DownloadConnection,
receivedData,
delegate,
percentComplete,
operationIsOK,
appendIfExist,
possibleFilename;

- (void) forceStop {
	operationBreaked = YES;
}

- (void) forceContinue {
	operationBreaked = NO;
	
//	NSLog(@"%f",bytesReceived);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: downloadUrl];
	
	[request addValue: [NSString stringWithFormat: @"bytes=%.0f-", bytesReceived ] forHTTPHeaderField: @"Range"];	
	
	DownloadConnection = [NSURLConnection connectionWithRequest:request
												  delegate: self];	
}


- (DownloadPercentObject *)initWithURL:(NSURL *)fileURL timeout:(NSInteger)timeout delegate:(id<DownloadPercentDelegate>)theDelegate {
	self = [super init];
	if(self) {
		self.delegate = theDelegate;
		downloadUrl = fileURL;
		bytesReceived = percentComplete = 0;
		localFilename = [[[fileURL absoluteString] lastPathComponent] copy];
		receivedData = [[NSMutableData alloc] initWithLength:0];
		DownloadRequest = [[NSURLRequest alloc] initWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
		DownloadConnection = [[NSURLConnection alloc] initWithRequest:DownloadRequest delegate:self startImmediately:YES];
				
		if(DownloadConnection == nil) {
			[self.delegate downloadObject:self didFailWithError:[NSError errorWithDomain:@"UIDownloadBar Error" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"NSURLConnection Failed", NSLocalizedDescriptionKey, nil]]];
		}
	}
	NSLog(@"I will start download:%@",fileURL);
	return self;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

	if (!operationBreaked) {
			
		[self.receivedData appendData:data];
		
		float receivedLen = [data length];
		bytesReceived = (bytesReceived + receivedLen);
		
		if(expectedBytes != NSURLResponseUnknownLength) {
			percentComplete = ((bytesReceived/(float)expectedBytes)*100);
		}
        NSLog(@" Data receiving... Percent complete: %f", percentComplete);
		
		[delegate downloadObjectUpdated:self];
	
	} else {
		[connection cancel];
		NSLog(@" STOP !!!!  Receiving data was stoped");
	}
		
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self.delegate downloadObject:self didFailWithError:error];
	operationFailed = YES;
	[connection release];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	NSLog(@"[DO::didReceiveData] %d operation", (int)self);
	NSLog(@"[DO::didReceiveData] ddb: %.2f, wdb: %.2f, ratio: %.2f", 
		  (float)bytesReceived, 
		  (float)expectedBytes,
		  (float)bytesReceived / (float)expectedBytes);
	
	NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
	NSDictionary *headers = [r allHeaderFields];
	NSLog(@"[DO::didReceiveResponse] response headers: %@", headers);
	if (headers){
		if ([headers objectForKey: @"Content-Range"]) {
			NSString *contentRange = [headers objectForKey: @"Content-Range"];
			NSLog(@"Content-Range: %@", contentRange);
			NSRange range = [contentRange rangeOfString: @"/"];
			NSString *totalBytesCount = [contentRange substringFromIndex: range.location + 1];
			expectedBytes = [totalBytesCount floatValue];
		} else if ([headers objectForKey: @"Content-Length"]) {
			NSLog(@"Content-Length: %@", [headers objectForKey: @"Content-Length"]);
			expectedBytes = [[headers objectForKey: @"Content-Length"] floatValue];
		} else expectedBytes = -1;
		
		if ([@"Identity" isEqualToString: [headers objectForKey: @"Transfer-Encoding"]]) {
			expectedBytes = bytesReceived;
			operationFinished = YES;
		}
	}		
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.delegate downloadObject:self didFinishWithData:self.receivedData suggestedFilename:localFilename];
	operationFinished = YES;
	NSLog(@"Connection did finish loading...");
}


- (void)dealloc {
	[possibleFilename release];
	[localFilename release];
	[receivedData release];
	[DownloadRequest release];
	[super dealloc];
}

@end
