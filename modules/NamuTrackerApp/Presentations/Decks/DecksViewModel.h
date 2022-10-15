//
//  DecksViewModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef UICollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> DecksViewModelDataSource;

@interface DecksViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(DecksViewModelDataSource *)dataSource NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
