//
//  FluentWallaperProvider.h
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import <Foundation/Foundation.h>
#import "FluentWallpaper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FluentWallaperProvider : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCompletionHandler:(void (^)(NSArray<FluentWallpaper *> * _Nullable fluentWallpapers, NSError * _Nullable error))completionHandler;
- (void)start;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
