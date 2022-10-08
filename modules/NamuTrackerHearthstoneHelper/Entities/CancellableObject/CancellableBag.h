#import <Foundation/Foundation.h>
#import "CancellableObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CancellableBag : NSObject
- (void)addCancellable:(CancellableObject *)cancellable;
- (void)removeCancellable:(CancellableObject *)cancellable;
- (void)removeAllCancellables;
@end

NS_ASSUME_NONNULL_END
