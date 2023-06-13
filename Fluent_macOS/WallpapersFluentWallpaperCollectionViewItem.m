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
@end

@implementation WallpapersFluentWallpaperCollectionViewItem

- (void)dealloc {
    [_fluentWallpaper release];
    [_downloader release];
    [_progress cancel];
    [_progress release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAttributes];
    [self setupDownloader];
}

- (void)setupWithFluentWallpaper:(FluentWallpaper *)fluentWallpaper {
    if ([fluentWallpaper isEqual:self.fluentWallpaper]) return;
    
    [self.progress cancel];
    self.view.layer.contents = nil;;
    
    static NSString * const key = @"WallpapersFluentWallpaperCollectionViewItemFluentWallpaperKey";
    NSDictionary *userInfo = @{key: fluentWallpaper};
    
    [self.downloader downloadFromURL:fluentWallpaper.thumbnailImageURL userInfo:userInfo didReceiveDataHandler:^(NSProgress * _Nullable progress, NSData * _Nullable data, NSDictionary * _Nullable out_userInfo, NSError * _Nullable error) {
        if (progress.isCancelled) {
            NSLog(@"Cancelled! %@", error);
            return;
        }
        if (![userInfo isEqualToDictionary:out_userInfo]) {
            NSLog(@"Different!");
            return;
        }
        
        NSImage *image = [[NSImage alloc] initWithData:data];
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            self.progress = progress;
            self.view.layer.contents = image;
        }];
        [image release];
    }];
    
    self.fluentWallpaper = fluentWallpaper;
}

- (void)setupAttributes {
    self.view.wantsLayer = YES;
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 10.f;
}

- (void)setupDownloader {
    NetworkDownloader *downloader = [NetworkDownloader new];
    self.downloader = downloader;
    [downloader release];
}

@end
