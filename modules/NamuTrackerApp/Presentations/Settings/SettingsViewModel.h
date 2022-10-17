//
//  SettingsViewModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import <UIKit/UIKit.h>
#import "SettingsSectionModel.h"
#import "SettingsItemModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef UICollectionViewDiffableDataSource<SettingsSectionModel *, SettingsItemModel *> SettingsDataSource;

typedef void (^SettingsViewModelReloadAlternativeHSCardsCompletion)(NSError * _Nullable error);
typedef void (^SettingsViewModelDeleteAllDataCachesCompletion)(NSError * _Nullable error);

static NSNotificationName const NSNotificationNameSettingsViewModelSelectedItemModel = @"NSNotificationNameSettingsViewModelSelectedItemModel";
static NSString * const SettingsViewModelSelectedItemModelKey = @"SettingsViewModelSelectedItemModelKey";

@interface SettingsViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(SettingsDataSource *)dataSource NS_DESIGNATED_INITIALIZER;
- (SettingsSectionModel *)sectionModelForIndexPath:(NSIndexPath *)indexPath;
- (void)requestItemModelFromIndexPath:(NSIndexPath *)indexPath;
- (BOOL)canHandleIndexPath:(NSIndexPath *)indexPath;
- (void)reloadAlternativeHSCardsWithCompletion:(SettingsViewModelReloadAlternativeHSCardsCompletion)completion;
- (void)deleteAllDataCachesWithCompletion:(SettingsViewModelDeleteAllDataCachesCompletion)completion;
@end

NS_ASSUME_NONNULL_END
