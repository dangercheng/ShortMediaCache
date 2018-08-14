//
//  ViewController.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ViewController.h"
#import "PlayerCell.h"

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
    
    //@"http://jmvideo.jumei.com/MzYxODE0NzE2/MTUzMzcyMzAyMTMwMg_E_E/MTk1Njg2Mjg_E/MjAxODA4MDgxODEwMDc1ODNtZXJnZS5tcDQ_E_default.mp4",
    //@"http://jmvideo.jumei.com/MzU3MTc2NjYx/MTUzMTk5MzU0MTY0Mw_E_E/MTQxMDE2NTk_E/MjAxODA3MTkxNzQ1MjE4NzVtZXJnZS5tcDQ_E_default.mp4",
    
//    NSArray *videoUrls = @[
//                           @"http://jmdianbostag.ks3-cn-beijing.ksyun.com/MjQ0NzY5NDU2/MTUxNjY5NzAzNTgwNg_E_E/OTQ2NTc2MA_E_E/MDY2OTVDOUItMzYwNi00MUM1LUJFRUQtRjJCQkJGOThFOTIyLk1PVg_E_E_default.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMTY5NjE3NA_E_E/OTAzNjQ2/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1NzUyODQ4Mjc1MjY3OTQ1MDMvdmlkZW8ubXA0.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMTMzOTEzMA_E_E/MjQzOTE4Ng_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MzI5OTQxOTIxNDA5MzAzMTcvdmlkZW8ubXA0.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMTgyNzkxMQ_E_E/MjQ2NDU2Mg_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1NDE2OTA3ODAxMTE2MDQ5OTYvdmlkZW8ubXA0.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMjMxMzcxNw_E_E/MTEwODU4Nw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MjcxNjgzNTE2NjIyNDcxODEvdmlkZW8ubXA0.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQyMTU4NzczMQ_E_E/MjE1MzE0Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MzgxNzU0MzQ5MDU4ODE4NjMvdmlkZW8ubXA0.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQzNDc5MTUwOA_E_E/ODk3Mjg1/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1ODA4OTQwOTI1Mzg5NDA2NzYvdmlkZW8ubXA0.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjUxMjE1NDY2Nw_E_E/OTI1ODU4Mg_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1Njc5ODM4NTg0Mzg5MDA5OTUvdmlkZW8ubXA0.mp4",
//                           @"http://jmvideo.jumei.com/MQ_E_E/MTUyMjY1NDAwOTg3Nw_E_E/MjYxMTg2Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MTkyNDcwMzQ4NjY3MzIzMDIvdmlkZW8ubXA0.mp4"];
    
    NSArray *videoUrls = @[
    @"http://jmdianbostag.ks3-cn-beijing.ksyun.com/MjQ0NzY5NDU2/MTUxNjY5NzAzNTgwNg_E_E/OTQ2NTc2MA_E_E/MDY2OTVDOUItMzYwNi00MUM1LUJFRUQtRjJCQkJGOThFOTIyLk1PVg_E_E_default.mp4",
    @"http://jmdianbostag.ks3-cn-beijing.ksyun.com/MTE1NzIzNzAz/MTUxNjUzNzA4MDk4Nw_E_E/MTAyNzE1NDM_E/dHJpbS4wN0JDOTEzMy01M0VELTQ5OUQtOTY2RS1GNUM4NDZEMUY5OTAuTU9W_default.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MjA2ODI4OQ_E_E/Mjg1NTk4OQ_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOThiNGUyNzEzMzIyMGMyMTdhZmU2Y2FhMWEyYTZlZDUvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTA4MjUxMA_E_E/Mzg0NTAxMA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTdkNDRlNTQ5NTM5NjZhMWZmZDA1OTRlYzhlNzQwYmMvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTM1NTUwNDYxNQ_E_E/MjEyNzc3MA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MjQwOTQ0MzEzMjk1MjA5MDQvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MjA5MzQ4Ng_E_E/MjcwNTgwOA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOThiYTA0MTZiNTU3NGVhN2QxMjA4MGZlMzdiYmI0MWIvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTkwMDA3MA_E_E/NDA0NDkzNA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTg3N2Y3ZTM2YTYzN2I2ZjY2OTE0ZGU1YjIxNDFkZDQvdmlkZW8ubXA0.mp4",
    @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTA2NTQ1OA_E_E/NDE0OTE2Nw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTdjZWI5ODk3Yzk1NTY1MjBmY2E0NjZmZTI4MmQ0MmUvdmlkZW8ubXA0.mp4"];
    _videoUrls = videoUrls;
}

- (void)viewDidAppear:(BOOL)animated {
//    [_collectionView reloadData];
    [self scrollViewDidEndDecelerating:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _videoUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"enddisplay index: %ld", indexPath.row);
    PlayerCell *playerCell = (PlayerCell*)cell;
    [playerCell stopPlay];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.y / _collectionView.frame.size.height;
    NSArray *visibleCells = _collectionView.visibleCells;
    PlayerCell *cell = visibleCells.firstObject;
    NSString *videoStr = [_videoUrls objectAtIndex:index];
    [cell playVideoWithUrl:[NSURL URLWithString:videoStr]];
    NSLog(@"scroll to index: %ld", index);
}

@end
