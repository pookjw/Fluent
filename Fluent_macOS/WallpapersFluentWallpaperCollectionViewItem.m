//
//  WallpapersFluentWallpaperCollectionViewItem.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "WallpapersFluentWallpaperCollectionViewItem.h"
@import FluentCore;

@interface WallpapersFluentWallpaperCollectionViewItem ()
@property (retain) FluentWallpaper *fluentWallpaper;
@property (retain) NetworkDownloader *downloader;
@property (retain) NSProgress *progress;
@property (retain) NSOperationQueue *queue;
@end

@implementation WallpapersFluentWallpaperCollectionViewItem

- (void)dealloc {
    [_fluentWallpaper release];
    [_downloader release];
    [_queue addOperationWithBlock:^{
        [_progress cancel];
        [_progress release];
    }];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAttributes];
    [self setupDownloader];
}

- (void)setupWithFluentWallpaper:(FluentWallpaper *)fluentWallpaper {
    if ([fluentWallpaper isEqual:self.fluentWallpaper]) return;
    
    NSMutableData *partialData = [NSMutableData new];
    [self.downloader downloadFromURL:fluentWallpaper.thumbnailImageURL didReceiveDataHandler:^(NSProgress * _Nullable progress, NSData * _Nullable data, BOOL isPartial, NSError * _Nullable error) {
        [partialData appendData:data];
        NSImage *image = [[NSImage alloc] initWithData:partialData];
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            self.view.layer.contents = image;
        }];
        [image release];
    }];
    [partialData release];
    
    self.fluentWallpaper = fluentWallpaper;
}

- (void)setupAttributes {
    self.view.wantsLayer = YES;
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.view.layer.masksToBounds = YES;
}

- (void)setupDownloader {
    NetworkDownloader *downloader = [NetworkDownloader new];
    self.downloader = downloader;
    [downloader release];
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceUserInitiated;
    queue.maxConcurrentOperationCount = 1;
    self.queue = queue;
    [queue release];
}

@end
