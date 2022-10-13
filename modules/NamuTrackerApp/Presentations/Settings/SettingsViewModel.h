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

static NSNotificationName const NSNotificationNameSettingsViewModelSelectedItemModel = @"NSNotificationNameSettingsViewModelSelectedItemModel";
static NSString * const SettingsViewModelSelectedItemModelKey = @"SettingsViewModelSelectedItemModelKey";

@interface SettingsViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(SettingsDataSource *)dataSource NS_DESIGNATED_INITIALIZER;
- (void)handleSelectedIndexPath:(NSIndexPath *)selectedIndexPath;
- (BOOL)canHandleIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
