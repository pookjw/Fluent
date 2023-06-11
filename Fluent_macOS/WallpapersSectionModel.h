//
//  WallpapersSectionModel.h
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WallpapersSectionModelType) {
    WallpapersSectionModelTypeFluentWallpapers
};

@interface WallpapersSectionModel : NSObject
@property (readonly, assign) WallpapersSectionModelType type;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(WallpapersSectionModelType)type;
@end

NS_ASSUME_NONNULL_END
