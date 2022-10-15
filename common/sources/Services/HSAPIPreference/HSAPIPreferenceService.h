//
//  HSAPIPreferenceService.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import <Foundation/Foundation.h>
#import "HSAPIRegionHost.h"
#import "HSAPILocale.h"

NS_ASSUME_NONNULL_BEGIN

static NSNotificationName const NSNotificationNameHSAPIPreferenceServiceDidSave = @"NSNotificationNameHSAPIPreferenceServiceDidSave";
typedef void (^HSAPIPreferenceServiceFetchRegionHostAndLocaleCompletion)(HSAPIRegionHost regionHost, HSAPILocale locale);

@interface HSAPIPreferenceService : NSObject
@property (class, readonly, strong, nonatomic) HSAPIPreferenceService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)fetchRegionHostAndLocaleWithCompletion:(HSAPIPreferenceServiceFetchRegionHostAndLocaleCompletion)completion;
- (void)updateRegionHost:(HSAPIRegionHost)regionHost;
- (void)updateLocale:(HSAPILocale)locale;
@end

NS_ASSUME_NONNULL_END
