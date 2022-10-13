#import "UICollectionViewDiffableDataSource+applySnapshotAndWait.h"

@implementation UICollectionViewDiffableDataSource (applySnapshotAndWait)

- (void)applySnapshotAndWait:(NSDiffableDataSourceSnapshot *)snapshot animatingDifferences:(BOOL)animatingDifferences completion:(void (^ _Nullable)(void))completion {
    if (NSThread.isMainThread) {
        [self applySnapshot:snapshot animatingDifferences:animatingDifferences completion:completion];
    } else {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self applySnapshot:snapshot animatingDifferences:animatingDifferences completion:^{
                if (completion) completion();
                dispatch_semaphore_signal(semaphore);
            }];
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
- (void)applySnapshotUsingReloadDataAndWait:(NSDiffableDataSourceSnapshot *)snapshot completion:(void (^ _Nullable)(void))completion {
    if (NSThread.isMainThread) {
        [self applySnapshotUsingReloadData:snapshot completion:completion];
    } else {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self applySnapshotUsingReloadData:snapshot completion:^{
                if (completion) completion();
                dispatch_semaphore_signal(semaphore);
            }];
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}
#pragma clang diagnostic pop

@end
