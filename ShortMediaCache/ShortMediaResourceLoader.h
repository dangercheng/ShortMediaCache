//
//  ShortMediaResourceLoader.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ShortMediaManager.h"

@protocol ShortMediaResourceLoaderDelegate <NSObject>
@end

@interface ShortMediaResourceLoader : NSObject

- (instancetype)initWithDelegate:(id<ShortMediaResourceLoaderDelegate>)delegate;

@property (nonatomic, strong, readonly) NSURL *url;

@property (nonatomic, weak) id<ShortMediaResourceLoaderDelegate> delegate;

- (AVPlayerItem *)playItemWithUrl:(NSURL *)url;

- (AVPlayerItem *)playItemWithUrl:(NSURL *)url options:(ShortMediaOptions)options;

- (void)endLoading;

@end
