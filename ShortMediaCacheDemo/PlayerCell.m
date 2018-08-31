//
//  PlayerCell.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/8/9.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "PlayerCell.h"
#import "ShortMediaResourceLoader.h"

#import <AVFoundation/AVFoundation.h>

@implementation PlayerCell {
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    ShortMediaResourceLoader *_resourceLoader;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.playerView.backgroundColor = [UIColor colorWithRed:arc4random() % 100 / 256.0 green:arc4random() % 100 / 256.0 blue:arc4random() % 100 / 256.0 alpha:1.0];
}

- (void)playVideoWithUrl:(NSURL *)videoUrl {
    if(!videoUrl) {
        return;
    }
    if(_player) {
        return;
    }
    _resourceLoader = [ShortMediaResourceLoader new];
    _playerItem = [_resourceLoader playItemWithUrl:videoUrl];
    
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = _playerView.bounds;
    [self.playerView.layer addSublayer:_playerLayer];
    [_player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"Complete.");
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopPlayWithUrl:_resourceLoader.url];
}

- (void)stopPlayWithUrl:(NSURL *)videoUrl {
    if(![videoUrl isEqual:_resourceLoader.url]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_player) {
        [_player pause];
        [_resourceLoader endLoading];
        AVURLAsset *asset = (AVURLAsset *)_playerItem.asset;
        [asset.resourceLoader setDelegate:nil queue:dispatch_get_main_queue()];
        [_playerLayer removeFromSuperlayer];
        _resourceLoader = nil;
        _playerItem = nil;
        _player = nil;
        _playerLayer = nil;
    }
}

@end
