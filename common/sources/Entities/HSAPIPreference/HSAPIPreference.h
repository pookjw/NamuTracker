//
//  HSAPIPreference.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/15/22.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSAPIPreference : NSManagedObject
@property (strong) NSNumber * _Nullable regionHost;
@property (strong) NSString * _Nullable locale;
@end

NS_ASSUME_NONNULL_END
