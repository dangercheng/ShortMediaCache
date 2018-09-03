# ShortMediaCache

A Cache Library based on AVPLayer for short video on ios, you can creat AVPlayerItem with it directly.

[中文介绍](https://segmentfault.com/a/1190000016228456)

## Main features
- **1.Designed for short video, easy to access, does not encroach on business**
- **2.cache video while playing, Play directly after caching**
- **3.Support preloading, Play the next video in one second**
- **4.Automatic cache management**

## Installation

**cocoapods**

```
pod 'ShortMediaCache'
```

## Usage

**Normal**

```
#import "ShortMediaResourceLoader.h"
```

```
ShortMediaResourceLoader _resourceLoader = [ShortMediaResourceLoader new];
AVPlayerItem _playerItem = [_resourceLoader playItemWithUrl:videoUrl]; 
AVPlayer _player = [AVPlayer playerWithPlayerItem:_playerItem];
```

tips: should hold the _resourceLoader object. 

**Preloading**

```
[[ShortMediaManager shareManager] resetPreloadingWithMediaUrls:preloadUrls];
```

tips:'preloadUrls' is an array with video urls

**More detail**

The source code

**License**

MIT
