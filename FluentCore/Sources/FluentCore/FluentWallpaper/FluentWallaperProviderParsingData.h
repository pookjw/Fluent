//
//  FluentWallaperProviderParsingData.h
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import <Foundation/Foundation.h>
#import "FluentWallpaper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FluentWallaperProviderParsingData : NSObject
@property (retain, readonly) NSMutableArray<FluentWallpaper *> *fluentWallpapers;
@property (assign) BOOL foundListItem;
@property (retain, nullable) NSString *imageURLPath;
@property (retain, nullable) NSString *thumbnailImagePath;
@property (retain, nullable) NSString *title;
- (void)cleanup;
@end

NS_ASSUME_NONNULL_END
