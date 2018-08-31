//
//  ViewController.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ViewController.h"
#import "PlayerCell.h"
#import "ShortMediaManager.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *videoUrls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _collectionView.collectionViewLayout = flowLayout;

    NSArray *videoUrls = @[
    @"http://jmdianbostag.ks3-cn-beijing.ksyun.com/MjQ0NzY5NDU2/MTUxNjY5NzAzNTgwNg_E_E/OTQ2NTc2MA_E_E/MDY2OTVDOUItMzYwNi00MUM1LUJFRUQtRjJCQkJGOThFOTIyLk1PVg_E_E_default.mp4",
    @"http://jmdianbostag.ks3-cn-beijing.ksyun.com/MTE1NzIzNzAz/MTUxNjUzNzA4MDk4Nw_E_E/MTAyNzE1NDM_E/dHJpbS4wN0JDOTEzMy01M0VELTQ5OUQtOTY2RS1GNUM4NDZEMUY5OTAuTU9W_default.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MjA2ODI4OQ_E_E/Mjg1NTk4OQ_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOThiNGUyNzEzMzIyMGMyMTdhZmU2Y2FhMWEyYTZlZDUvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTA4MjUxMA_E_E/Mzg0NTAxMA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTdkNDRlNTQ5NTM5NjZhMWZmZDA1OTRlYzhlNzQwYmMvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTM1NTUwNDYxNQ_E_E/MjEyNzc3MA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MjQwOTQ0MzEzMjk1MjA5MDQvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MjA5MzQ4Ng_E_E/MjcwNTgwOA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOThiYTA0MTZiNTU3NGVhN2QxMjA4MGZlMzdiYmI0MWIvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTkwMDA3MA_E_E/NDA0NDkzNA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTg3N2Y3ZTM2YTYzN2I2ZjY2OTE0ZGU1YjIxNDFkZDQvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTA2NTQ1OA_E_E/NDE0OTE2Nw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTdjZWI5ODk3Yzk1NTY1MjBmY2E0NjZmZTI4MmQ0MmUvdmlkZW8ubXA0.mp4",
   @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMjMxMzcxNw_E_E/MTEwODU4Nw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MjcxNjgzNTE2NjIyNDcxODEvdmlkZW8ubXA0.mp4",
   @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQyMTU4NzczMQ_E_E/MjE1MzE0Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MzgxNzU0MzQ5MDU4ODE4NjMvdmlkZW8ubXA0.mp4",
   @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQzNDc5MTUwOA_E_E/ODk3Mjg1/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1ODA4OTQwOTI1Mzg5NDA2NzYvdmlkZW8ubXA0.mp4",
   @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjUxMjE1NDY2Nw_E_E/OTI1ODU4Mg_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1Njc5ODM4NTg0Mzg5MDA5OTUvdmlkZW8ubXA0.mp4",
   @"http://jmvideo.jumei.com/MQ_E_E/MTUyMjY1NDAwOTg3Nw_E_E/MjYxMTg2Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MTkyNDcwMzQ4NjY3MzIzMDIvdmlkZW8ubXA0.mp4"];
    _videoUrls = videoUrls;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollViewDidEndDecelerating:_collectionView];
    _collectionView.contentOffset = CGPointZero;
}

- (IBAction)clickCleanCacheBtn:(UIButton *)sender {
    NSString *cachedSizeStr = [[ShortMediaManager shareManager] totalCachedSizeStr];
    NSString *message = [NSString stringWithFormat:@"Confirm to clean cache? \n cache size:%@", cachedSizeStr];
    UIAlertController *alertControoler = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ShortMediaManager shareManager] cleanCache];
    }];
    [alertControoler addAction:cancelAction];
    [alertControoler addAction:okAction];
    [self presentViewController:alertControoler animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _videoUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"1====>enddisplay index: %ld, cell: %@, visibleCells: %@",(long)indexPath.row, cell, collectionView.visibleCells);
    PlayerCell *playerCell = (PlayerCell*)cell;
    NSString *videoStr = [_videoUrls objectAtIndex:indexPath.row];
    [playerCell stopPlayWithUrl:[NSURL URLWithString:videoStr]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        NSInteger index = scrollView.contentOffset.y / self.collectionView.frame.size.height;
        NSArray *visibleCells = self.collectionView.visibleCells;
        NSString *videoStr = [self.videoUrls objectAtIndex:index];
        PlayerCell *cell = visibleCells.lastObject;
        NSLog(@"2====>scroll to cell %@ index: %ld, visibleCells:%d",cell, (long)index, visibleCells.count);
        [cell playVideoWithUrl:[NSURL URLWithString:videoStr]];
        [self resetPreloadWithIndex:index];
    });
}

- (void)resetPreloadWithIndex:(NSInteger)index {
    index ++;
    if(index >= _videoUrls.count) {
        return;
    }
    NSInteger maxPreloadCount = 3;
    NSMutableArray *preloadUrls = [NSMutableArray arrayWithCapacity:maxPreloadCount];
    for(NSInteger i = index; i < _videoUrls.count; i++) {
        NSString *videoUrlStr = _videoUrls[i];
        NSURL *videoUrl = [NSURL URLWithString:videoUrlStr];
        if(videoUrl) {
            [preloadUrls addObject:videoUrl];
            if(preloadUrls.count == maxPreloadCount) {
                break;
            }
        }
    }
    [[ShortMediaManager shareManager] resetPreloadingWithMediaUrls:preloadUrls];
}

@end
