//
//  ShortMediaDownloadOperation.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortMediaCache.h"
#import "ShortMediaDownloader.h"

@interface ShortMediaDownloadOperation : NSOperation <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, assign) ShortMediaOptions options;

@property (nonatomic, strong) NSURLCredential *credential;

@property (nonatomic, assign) BOOL isPreloading;

- (instancetype)initWithRequest:(NSURLRequest *)request
                        session:(NSURLSession *)session
                        options:(ShortMediaOptions)options
                       progress:(ShortMediaProgressBlock)progress
                     completion:(ShortMediaCompletionBlock)completion;

- (void)cancelOperation;
@end
