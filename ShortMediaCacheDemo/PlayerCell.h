//
//  PlayerCell.h
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/9.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *playerView;

- (void)stopPlay;

- (void)playVideoWithUrl:(NSURL *)videlUrl;

@end
