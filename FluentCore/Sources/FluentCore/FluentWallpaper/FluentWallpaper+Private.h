//
//  FluentWallpaper+Private.h
//
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import "FluentWallpaper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FluentWallpaper (Private)
- (instancetype)initWithTitle:(NSString *)name thumbnailImageURL:(NSURL *)thumbnailImageURL imageURL:(NSURL *)imageURL;
@end

NS_ASSUME_NONNULL_END
