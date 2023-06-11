//
//  WallpapersItemModel.h
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import <Foundation/Foundation.h>
@import FluentCore;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WallpapersItemModelType) {
    WallpapersItemModelTypeFluentWallpaper
};

@interface WallpapersItemModel : NSObject
@property (readonly, assign) WallpapersItemModelType type;
@property (readonly, retain, nullable) FluentWallpaper *fluentWallpaper;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFluentWallpaper:(FluentWallpaper *)fluentWallpaper;
@end

NS_ASSUME_NONNULL_END
