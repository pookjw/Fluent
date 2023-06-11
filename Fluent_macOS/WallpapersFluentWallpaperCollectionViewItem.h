//
//  WallpapersFluentWallpaperCollectionViewItem.h
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import <Cocoa/Cocoa.h>
@import FluentCore;

NS_ASSUME_NONNULL_BEGIN

static NSUserInterfaceItemIdentifier const NSUserInterfaceItemIdentifierWallpapersFluentWallpaperCollectionViewItem = @"NSUserInterfaceItemIdentifierWallpapersFluentWallpaperCollectionViewItem";

@interface WallpapersFluentWallpaperCollectionViewItem : NSCollectionViewItem
- (void)setupWithFluentWallpaper:(FluentWallpaper *)fluentWallpaper;
@end

NS_ASSUME_NONNULL_END
