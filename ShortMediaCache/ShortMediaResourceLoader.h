//
//  ShortMediaResourceLoader.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol ShortMediaResourceLoaderDelegate <NSObject>
@end

@interface ShortMediaResourceLoader : NSObject

@property (nonatomic, weak) id<ShortMediaResourceLoaderDelegate> delegate;

- (AVPlayerItem *)playItemWithUrl:(NSURL *)url;

- (void)endLoading;

@end
