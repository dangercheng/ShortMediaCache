//
//  ShortMediaDownloader.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/7.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortMediaCache.h"

typedef NS_OPTIONS(NSUInteger, ShortMediaOptions) {
    ShortMediaOptionsHandleCookies = 1 << 0,
    ShortMediaOptionsOptionAllowInvalidSSLCertificates = 1 << 1,
};

typedef void(^ShortMediaProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void(^ShortMediaCompletionBlock)(NSError *error);

@interface ShortMediaDownloader : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign, readonly) BOOL canPreload;

+ (instancetype)shareDownloader;

- (void)downloadMediaWithUrl:(NSURL *)url
                     options:(ShortMediaOptions)options
                    progress:(ShortMediaProgressBlock)progress
                  completion:(ShortMediaCompletionBlock)completion;

- (void)preloadMediaWithUrl:(NSURL *)url
                    options:(ShortMediaOptions)options
                   progress:(ShortMediaProgressBlock)progress
                 completion:(ShortMediaCompletionBlock)completion;

- (void)cancelDownloadWithUrl:(NSURL *)url;

@end
