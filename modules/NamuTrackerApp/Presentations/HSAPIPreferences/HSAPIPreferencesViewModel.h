//
//  HSAPIPreferencesViewModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/16/22.
//

#import <UIKit/UIKit.h>
#import "HSAPIPreferencesSectionModel.h"
#import "HSAPIPreferencesItemModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef UICollectionViewDiffableDataSource<HSAPIPreferencesSectionModel *, HSAPIPreferencesItemModel *> HSAPIPreferencesDataSource;

@interface HSAPIPreferencesViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(HSAPIPreferencesDataSource *)dataSource NS_DESIGNATED_INITIALIZER;
- (HSAPIPreferencesSectionModel *)sectionModelForIndexPath:(NSIndexPath *)indexPath;
- (void)handleSelectedIndexPath:(NSIndexPath *)selectedIndexPath;
@end

NS_ASSUME_NONNULL_END
