//
//  HSAPIPreferencesItemModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/16/22.
//

#import <Foundation/Foundation.h>
#import "HSAPIRegionHost.h"
#import "HSAPILocale.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HSAPIPreferencesItemModelType) {
    HSAPIPreferencesItemModelTypeHSAPIRegionHost,
    HSAPIPreferencesItemModelTypeHSAPILocale
};

@interface HSAPIPreferencesItemModel : NSObject
@property (readonly) HSAPIPreferencesItemModelType type;
@property (readonly, nonatomic) NSString * _Nullable text;
@property (getter=isSelected) BOOL selected;
@property (readonly, strong) NSNumber * _Nullable hsAPIRegionHost;
@property (readonly, copy) HSAPILocale _Nullable hsAPILocale;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHSAPIRegionHost:(HSAPIRegionHost)hsAPIRegionHost isSelected:(BOOL)isSelected NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithHSAPILocale:(HSAPILocale)hsAPILocale isSelected:(BOOL)isSelected NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
