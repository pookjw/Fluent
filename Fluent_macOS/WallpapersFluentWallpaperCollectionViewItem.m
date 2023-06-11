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
    self.view.wantsLayer = YES;
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.view.layer.masksToBounds = YES;
}

- (void)setupWithFluentWallpaper:(FluentWallpaper *)fluentWallpaper {
    if ([fluentWallpaper isEqual:self.fluentWallpaper]) return;
    
    // TODO
    NSData *data = [[NSData alloc] initWithContentsOfURL:fluentWallpaper.thumbnailImageURL];
    NSImage *image = [[NSImage alloc] initWithData:data];
    [data release];
    self.view.layer.contents = image;
    [image release];
    
    self.fluentWallpaper = fluentWallpaper;
}

@end
