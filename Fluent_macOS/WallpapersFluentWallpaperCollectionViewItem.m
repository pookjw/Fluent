//
//  WallpapersFluentWallpaperCollectionViewItem.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "WallpapersFluentWallpaperCollectionViewItem.h"

@interface WallpapersFluentWallpaperCollectionViewItem ()
@property (retain) FluentWallpaper *fluentWallpaper;
@end

@implementation WallpapersFluentWallpaperCollectionViewItem

- (void)dealloc {
    [_fluentWallpaper release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupImageView];
}

- (void)setupWithFluentWallpaper:(FluentWallpaper *)fluentWallpaper {
    if ([fluentWallpaper isEqual:self.fluentWallpaper]) return;
    
    // TODO
    NSData *data = [[NSData alloc] initWithContentsOfURL:fluentWallpaper.thumbnailImageURL];
    NSImage *image = [[NSImage alloc] initWithData:data];
    [data release];
    self.imageView.image = image;
    [image release];
    
    self.fluentWallpaper = fluentWallpaper;
}

- (void)setupImageView {
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:self.view.bounds];
    imageView.imageScaling = NSImageScaleAxesIndependently;
    imageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    [imageView release];
}

@end
