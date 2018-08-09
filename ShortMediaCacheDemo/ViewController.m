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
    
    NSArray *videoUrls = @[
                           @"http://jmvideo.jumei.com/MzYxODE0NzE2/MTUzMzcyMzAyMTMwMg_E_E/MTk1Njg2Mjg_E/MjAxODA4MDgxODEwMDc1ODNtZXJnZS5tcDQ_E_default.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMTY5NjE3NA_E_E/OTAzNjQ2/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1NzUyODQ4Mjc1MjY3OTQ1MDMvdmlkZW8ubXA0.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMTMzOTEzMA_E_E/MjQzOTE4Ng_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MzI5OTQxOTIxNDA5MzAzMTcvdmlkZW8ubXA0.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMTgyNzkxMQ_E_E/MjQ2NDU2Mg_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1NDE2OTA3ODAxMTE2MDQ5OTYvdmlkZW8ubXA0.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMjMxMzcxNw_E_E/MTEwODU4Nw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MjcxNjgzNTE2NjIyNDcxODEvdmlkZW8ubXA0.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQyMTU4NzczMQ_E_E/MjE1MzE0Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MzgxNzU0MzQ5MDU4ODE4NjMvdmlkZW8ubXA0.mp4",
                           @"http://jmvideo.jumei.com/MzU3MTc2NjYx/MTUzMTk5MzU0MTY0Mw_E_E/MTQxMDE2NTk_E/MjAxODA3MTkxNzQ1MjE4NzVtZXJnZS5tcDQ_E_default.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQzNDc5MTUwOA_E_E/ODk3Mjg1/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1ODA4OTQwOTI1Mzg5NDA2NzYvdmlkZW8ubXA0.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjUxMjE1NDY2Nw_E_E/OTI1ODU4Mg_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1Njc5ODM4NTg0Mzg5MDA5OTUvdmlkZW8ubXA0.mp4",
                           @"http://jmvideo.jumei.com/MQ_E_E/MTUyMjY1NDAwOTg3Nw_E_E/MjYxMTg2Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MTkyNDcwMzQ4NjY3MzIzMDIvdmlkZW8ubXA0.mp4"];
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
