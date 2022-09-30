#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrackingWindow : UIWindow
- (void)makeKeyWindow NS_UNAVAILABLE;
- (void)makeKeyAndVisible NS_UNAVAILABLE;
- (void)resignKeyWindow NS_UNAVAILABLE;
- (void)present:(BOOL)animated;
- (void)dismiss:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
