//
//  LocalizableService.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import <Foundation/Foundation.h>
#import "LocalizableKey.h"
#import "HSAPIRegionHost.h"
#import "HSAPILocale.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalizableService : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (NSString *)localizableForKey:(LocalizableKey)key;
+ (NSString *)localizableForHSAPIRegionHost:(HSAPIRegionHost)hsAPIRegionHost;
+ (NSString *)localizableForHSAPILocale:(HSAPILocale)hsAPILocale;
@end

NS_ASSUME_NONNULL_END
