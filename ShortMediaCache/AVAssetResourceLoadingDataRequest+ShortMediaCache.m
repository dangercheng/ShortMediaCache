//
//  AVAssetResourceLoadingDataRequest+ShortMediaCache.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/9.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "AVAssetResourceLoadingDataRequest+ShortMediaCache.h"
#import <objc/runtime.h>

static const NSString *RespondedSizeKey = @"RespondedSizeKey";

@implementation AVAssetResourceLoadingDataRequest (ShortMediaCache)

- (void)setRespondedSize:(NSInteger)respondedSize {
    objc_setAssociatedObject(self, &RespondedSizeKey, [NSNumber numberWithInteger:respondedSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)respondedSize {
    NSNumber *value = objc_getAssociatedObject(self, &RespondedSizeKey);
    return [value integerValue];
}



@end
