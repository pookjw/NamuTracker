//
//  SettingsSectionModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SettingsSectionModelType) {
    SettingsSectionModelTypeNotices,
    SettingsSectionModelTypeGeneral
};

@interface SettingsSectionModel : NSObject
@property (readonly) SettingsSectionModelType type;
@property (readonly, nonatomic) NSString * _Nullable headerText;
@property (readonly, nonatomic) NSString * _Nullable footerText;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(SettingsSectionModelType)type NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
