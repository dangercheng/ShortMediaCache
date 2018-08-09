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

- (instancetype)initWithRequest:(NSURLRequest *)request
                        session:(NSURLSession *)session
                       progress:(ShortMediaProgressBlock)progress
                     completion:(ShortMediaCompletionBlock)completion;

- (void)cancelOperation;
@end
