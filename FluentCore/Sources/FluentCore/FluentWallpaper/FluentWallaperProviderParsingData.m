//
//  FluentWallaperProviderParsingData.m
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import "FluentWallaperProviderParsingData.h"

@interface FluentWallaperProviderParsingData ()
@property (retain) NSMutableArray<FluentWallpaper *> *fluentWallpapers;
@end

@implementation FluentWallaperProviderParsingData

- (instancetype)init {
    if (self = [super init]) {
        NSMutableArray<FluentWallpaper *> *fluentWallpapers = [NSMutableArray<FluentWallpaper *> new];
        self.fluentWallpapers = fluentWallpapers;
        [fluentWallpapers release];
    }
    
    return self;
}

- (void)dealloc {
    [_fluentWallpapers release];
    [_imageURLPath release];
    [_thumbnailImagePath release];
    [_title release];
    [super dealloc];
}

- (void)cleanup {
    self.foundListItem = YES;
    self.imageURLPath = nil;
    self.thumbnailImagePath = nil;
    self.title = nil;
}

@end
