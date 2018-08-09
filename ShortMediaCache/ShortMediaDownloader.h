//
//  ShortMediaDownloader.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/7.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortMediaCache.h"

typedef void(^ShortMediaProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void(^ShortMediaCompletionBlock)(NSError *error);

@interface ShortMediaDownloader : NSObject

+ (instancetype)shareDownloader;

- (void)downloadMediaWithUrl:(NSURL *)url
                    progress:(ShortMediaProgressBlock)progress
                  completion:(ShortMediaCompletionBlock)completion;

- (void)cancelDownloadWithUrl:(NSURL *)url;

@end
