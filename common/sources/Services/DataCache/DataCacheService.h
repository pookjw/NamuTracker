//
//  DataCacheService.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import <Foundation/Foundation.h>
#import "DataCache.h"

NS_ASSUME_NONNULL_BEGIN

static NSNotificationName const NSNotificationNameHSAPIPreferenceServiceDidSave = @"NSNotificationNameHSAPIPreferenceServiceDidSave";
typedef void (^DataCacheServiceFetchDataCachesWithIdentityCompletion)(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error);
typedef void (^DataCacheServiceCreateDataCacheCompletion)(DataCache * _Nullable dataCache, NSError * _Nullable error);
typedef void (^DataCacheServiceDeleteAllDataCachesCompletion)(NSError * _Nullable error);

@interface DataCacheService : NSObject
@property (class, readonly, strong, nonatomic) DataCacheService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)fetchDataCachesWithIdentity:(NSString *)identity completion:(DataCacheServiceFetchDataCachesWithIdentityCompletion)completion;
- (void)createDataCacheWithCompletion:(DataCacheServiceCreateDataCacheCompletion)completion;
- (void)deleteAllDataCachesWithCompletion:(DataCacheServiceDeleteAllDataCachesCompletion)completion;
- (void)saveChanges;
@end

NS_ASSUME_NONNULL_END
