#import <UIKit/UIKit.h>
#import "HSCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackingListCardContentConfiguration : NSObject <UIContentConfiguration>
@property (readonly, copy) HSCard *hsCard;
@property (readonly, copy) NSNumber *hsCardCount;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHSCard:(HSCard *)hsCard hsCardCount:(NSNumber *)hsCardCount;
@end

NS_ASSUME_NONNULL_END
