#import <Foundation/Foundation.h>
#import "HSCard.h"
#import "AlternativeHSCard.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TrackingListItemModelType) {
    TrackingListItemModelTypeHSCard,
    TrackingListItemModelTypeAlternativeHSCard
};

@interface TrackingListItemModel : NSObject <NSCopying>
@property (readonly) TrackingListItemModelType type;
@property (readonly, copy) HSCard * _Nullable hsCard;
@property (readonly, copy) AlternativeHSCard * _Nullable alternativeHSCard;
@property (copy) NSNumber * _Nullable hsCardCount;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHSCard:(HSCard *)hsCard hsCardCount:(NSNumber *)hsCardCount;
- (instancetype)initWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard hsCardCount:(NSNumber *)hsCardCount;
@end

NS_ASSUME_NONNULL_END
