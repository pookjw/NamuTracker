//
//  DataCache.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataCache : NSManagedObject
@property (strong) NSString * _Nullable identity;
@property (strong) NSData * _Nullable data;
@end

NS_ASSUME_NONNULL_END
