#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CancellableObject : NSObject
@property (readonly) BOOL isCancelled;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCancellationHandler:(void (^)(void))cancellationHandler;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
