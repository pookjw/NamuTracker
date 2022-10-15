#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrackingService : NSObject
@property (class, readonly, strong, nonatomic) TrackingService *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)startObserving;
- (void)stopObserving;
@end

NS_ASSUME_NONNULL_END
