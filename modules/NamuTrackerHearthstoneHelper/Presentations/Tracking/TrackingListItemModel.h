#import <Foundation/Foundation.h>
#import "HSCard.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TrackingListItemModelType) {
    TrackingListItemModelTypeCard
};

@interface TrackingListItemModel : NSObject
@property (readonly) TrackingListItemModelType type;
@property (readonly, copy) HSCard * _Nullable hsCard;
@property (copy) NSNumber * _Nullable hsCardCount;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHSCard:(HSCard *)hsCard hsCardCount:(NSNumber *)hsCardCount;
@end

NS_ASSUME_NONNULL_END
