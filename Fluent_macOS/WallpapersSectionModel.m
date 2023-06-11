//
//  WallpapersSectionModel.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import "WallpapersSectionModel.h"

@interface WallpapersSectionModel ()
@property (assign) WallpapersSectionModelType type;
@end

@implementation WallpapersSectionModel

- (instancetype)initWithType:(WallpapersSectionModelType)type {
    if (self = [self init]) {
        self.type = type;
    }
    
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        WallpapersSectionModel *toCompare = (WallpapersSectionModel *)other;
        return self.type == toCompare.type;
    }
}

- (NSUInteger)hash {
    return self.type;
}

@end
