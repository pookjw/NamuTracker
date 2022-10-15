//
//  SettingsItemModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SettingsItemModelType) {
    SettingsItemModelTypeUserlandNotice,
    SettingsItemModelTypeMockModeNotice,
    SettingsItemModelTypeDecks,
    SettingsItemModelTypeHSAPIPreferences
};

@interface SettingsItemModel : NSObject
@property (readonly) SettingsItemModelType type;
@property (readonly, nonatomic) NSString * _Nullable text;
@property (readonly, nonatomic) NSString * _Nullable secondaryText;
@property (readonly, nonatomic) UIImage * _Nullable image;
@property (readonly, nonatomic) NSArray<UICellAccessory *> *accessories;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(SettingsItemModelType)type NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
