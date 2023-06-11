//
//  WallpapersItemModel.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "WallpapersItemModel.h"

@interface WallpapersItemModel ()
@property (assign) WallpapersItemModelType type;
@property (retain, nullable) FluentWallpaper *fluentWallpaper;
@end

@implementation WallpapersItemModel

- (instancetype)initWithType:(WallpapersItemModelType)type {
    if (self = [self init]) {
        self.type = type;
    }
    
    return self;
}

- (instancetype)initWithFluentWallpaper:(FluentWallpaper *)fluentWallpaper {
    if (self = [self initWithType:WallpapersItemModelTypeFluentWallpaper]) {
        self.fluentWallpaper = fluentWallpaper;
    }
    
    return self;
}

- (void)dealloc {
    [_fluentWallpaper release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        WallpapersItemModel *toCompare = (WallpapersItemModel *)other;
        
        if (self.type != toCompare.type) {
            return NO;
        } else {
            switch (self.type) {
                case WallpapersItemModelTypeFluentWallpaper:
                    return [self.fluentWallpaper isEqual:toCompare.fluentWallpaper];
                default:
                    return NO;
            }
        }
    }
}

- (NSUInteger)hash {
    return self.type ^ self.fluentWallpaper.hash;
}

@end
