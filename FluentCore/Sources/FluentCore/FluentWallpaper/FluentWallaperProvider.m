//
//  FluentWallaperProvider.m
//  
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import "FluentWallaperProvider.h"
#import "FluentWallpaper+Private.h"
#import "FluentWallaperProviderParsingData.h"
#import "../RemoteInputStream/RemoteInputStream.h"
#import <objc/runtime.h>

@interface FluentWallaperProvider () <NSXMLParserDelegate>
@property (copy) void (^completionHandler)(NSArray<FluentWallpaper *> * _Nullable, NSError * _Nullable);
@property (retain) NSOperationQueue *queue;
@property (retain) NSOperationQueue *parsingQueue;
@property (retain) FluentWallaperProviderParsingData *parsingData;
@property (retain) NSXMLParser *parser;
@property (assign) BOOL isStarted;
@property (assign) BOOL isCancelled;
@property (readonly, nonatomic) NSURLComponents *baseURLComponents;
@end

@implementation FluentWallaperProvider

- (instancetype)initWithCompletionHandler:(void (^)(NSArray<FluentWallpaper *> * _Nullable, NSError * _Nullable))completionHandler {
    if (self = [self init]) {
        NSOperationQueue *queue = [NSOperationQueue new];
        queue.qualityOfService = NSQualityOfServiceBackground;
        queue.maxConcurrentOperationCount = 1;
        self.queue = queue;
        
        [queue addOperationWithBlock:^{
            self.completionHandler = completionHandler;
            
            NSOperationQueue *parsingQueue = [NSOperationQueue new];
            parsingQueue.qualityOfService = NSQualityOfServiceUserInitiated;
            parsingQueue.maxConcurrentOperationCount = 1;
            self.parsingQueue = parsingQueue;
            [parsingQueue release];
            
            FluentWallaperProviderParsingData *parsingData = [FluentWallaperProviderParsingData new];
            self.parsingData = parsingData;
            [parsingData release];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.baseURLComponents.URL];
            RemoteInputStream *inputStream = [[RemoteInputStream alloc] initWithRequest:request];
            [request release];
            
            NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:inputStream];
            [inputStream release];
            parser.delegate = self;
            
            self.parser = parser;
            [parser release];
        }];
        
        [queue release];
    }
    
    return self;
}

- (void)dealloc {
    [_completionHandler release];
    [_queue release];
    [_parsingQueue release];
    [_parsingData release];
    [_parser release];
    [super dealloc];
}

- (void)start {
    [self.queue addOperationWithBlock:^{
        if (self.isStarted || self.isCancelled) return;
        
        [self.parsingQueue addOperationWithBlock:^{
            BOOL success = [self.parser parse];
            
            if (success) {
                self.completionHandler(self.parsingData.fluentWallpapers, nil);
            } else {
                self.completionHandler(nil, self.parser.parserError);
            }
        }];
        
        self.isStarted = YES;
    }];
}

- (void)cancel {
    [self.queue addOperationWithBlock:^{
        if (!self.isStarted || self.isCancelled) return;
        self.isCancelled = YES;
    }];
}

- (NSURLComponents *)baseURLComponents {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"wallpapers.microsoft.design";
    
    return [components autorelease];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([@"li" isEqualToString:elementName] && ([@"listItem" isEqualToString:attributeDict[@"role"]])) {
        [self.parsingData cleanup];
        self.parsingData.foundListItem = YES;
    } else if (self.parsingData.foundListItem) {
        if ([@"a" isEqualToString:elementName]) {
            self.parsingData.imageURLPath = attributeDict[@"href"];
            self.parsingData.title = attributeDict[@"title"];
        } else if ([@"img" isEqualToString:elementName]) {
            self.parsingData.thumbnailImagePath = attributeDict[@"src"];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (!self.parsingData.foundListItem) {
        return;
    }
    
    if (!self.parsingData.imageURLPath || !self.parsingData.thumbnailImagePath) {
        return;
    }
    
    NSURL *imageURL = [[NSURL alloc] initWithString:self.parsingData.imageURLPath];
    if (!imageURL){
        NSLog(@"skipped");
        [self.parsingData cleanup];
        return;
    }
    
    NSURLComponents *thumbnailImageURLComponents = self.baseURLComponents;
    thumbnailImageURLComponents.path = [NSString stringWithFormat:@"/%@", self.parsingData.thumbnailImagePath];
    NSURL *thumbnailImageURL = thumbnailImageURLComponents.URL;
    if (!thumbnailImageURL){
        NSLog(@"skipped");
        [imageURL release];
        [self.parsingData cleanup];
        return;
    }
    
    NSString *title;
    if (self.parsingData.title) {
        title = self.parsingData.title;
    } else {
        title = @"(null)";
    }
    
    FluentWallpaper *fluentWallpaper = [[FluentWallpaper alloc] initWithTitle:title thumbnailImageURL:thumbnailImageURL imageURL:imageURL];
    [imageURL release];
    
    [self.parsingData.fluentWallpapers addObject:fluentWallpaper];
    [fluentWallpaper release];
    
    [self.parsingData cleanup];
}

@end
