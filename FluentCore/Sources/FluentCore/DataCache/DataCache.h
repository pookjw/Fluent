//
//  DataCache.h
//  
//
//  Created by Jinwoo Kim on 6/11/23.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataCache : NSManagedObject
@property (assign) NSString *identity;
@property (assign, nullable) NSData *data;
@end

NS_ASSUME_NONNULL_END
