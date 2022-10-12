#import <UIKit/UIKit.h>
#import "TrackingListSectionModel.h"
#import "TrackingListItemModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef UICollectionViewDiffableDataSource<TrackingListSectionModel *, TrackingListItemModel *> TrackingListDataSource;

@interface TrackingListViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(TrackingListDataSource *)dataSource NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
