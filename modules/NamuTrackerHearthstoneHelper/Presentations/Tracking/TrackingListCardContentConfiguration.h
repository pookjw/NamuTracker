#import <UIKit/UIKit.h>
#import "TrackingListItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackingListCardContentConfiguration : NSObject <UIContentConfiguration>
@property (readonly, copy) TrackingListItemModel *itemModel;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithItemModel:(TrackingListItemModel *)itemModel;
@end

NS_ASSUME_NONNULL_END
