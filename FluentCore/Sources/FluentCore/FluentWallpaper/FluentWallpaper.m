//
//  FluentWallpaper.m
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import "FluentWallpaper.h"
#import "FluentWallpaper+Private.h"

@interface FluentWallpaper ()
@property (copy) NSString *title;
@property (copy) NSURL *thumbnailImageURL;
@property (copy) NSURL *imageURL;
@end

@implementation FluentWallpaper

- (instancetype)initWithTitle:(NSString *)name thumbnailImageURL:(NSURL *)thumbnailImageURL imageURL:(NSURL *)imageURL {
    if (self = [self init]) {
        self.title = name;
        self.thumbnailImageURL = thumbnailImageURL;
        self.imageURL = imageURL;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *title = [coder decodeObjectForKey:@"title"];
    NSURL *thumbnailImageURL = [coder decodeObjectForKey:@"thumbnailImageURL"];
    NSURL *imageURL = [coder decodeObjectForKey:@"imageURL"];
    
    self = [self initWithTitle:title thumbnailImageURL:thumbnailImageURL imageURL:imageURL];
    
    return self;
}

- (void)dealloc {
    [_title release];
    [_thumbnailImageURL release];
    [_imageURL release];
    [super dealloc];
}

- (NSString *)description {
    NSDictionary *dictionary = @{
        @"title": self.title,
        @"thumbnailImageURL": self.thumbnailImageURL,
        @"imageURL": self.imageURL
    };
    
    return [NSString stringWithFormat:@"%@ %@", [super description], dictionary];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.thumbnailImageURL forKey:@"thumbnailImageURL"];
    [coder encodeObject:self.imageURL forKey:@"imageURL"];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    FluentWallpaper *copy = [[self.class alloc] initWithTitle:self.title thumbnailImageURL:self.thumbnailImageURL imageURL:self.imageURL];
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        FluentWallpaper *toCompare = (FluentWallpaper *)other;
        return ([self.title isEqualToString:toCompare.title]) && ([self.thumbnailImageURL isEqual:toCompare.thumbnailImageURL]) && ([self.imageURL isEqual:toCompare.imageURL]);
    }
}

- (NSUInteger)hash {
    return self.title.hash ^ self.thumbnailImageURL.hash ^ self.imageURL.hash;
}

@end
