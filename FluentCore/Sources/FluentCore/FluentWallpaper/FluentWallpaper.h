//
//  FluentWallpaper.h
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FluentWallpaper : NSObject <NSCopying, NSSecureCoding>
@property (readonly, copy) NSString *title;
@property (readonly, copy) NSURL *thumbnailImageURL;
@property (readonly, copy) NSURL *imageURL;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
