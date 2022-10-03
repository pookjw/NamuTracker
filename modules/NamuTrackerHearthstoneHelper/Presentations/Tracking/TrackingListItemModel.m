#import "TrackingListItemModel.h"
#import <compareNullableValues.h>

@implementation TrackingListItemModel

- (instancetype)initWithHSCard:(HSCard *)hsCard hsCardCount:(NSNumber *)hsCardCount {
    if (self = [self init]) {
        self->_type = TrackingListItemModelTypeCard;
        self->_hsCard = [hsCard copy];
        self.hsCardCount = hsCardCount;
    }

    return self;
}

- (BOOL)isEqual:(id)object {
    TrackingListItemModel *other = (TrackingListItemModel *)object;
    
    if (![other isKindOfClass:[TrackingListItemModel class]]) {
        return NO;
    }

    if ((self.type == TrackingListItemModelTypeCard) && (other.type == TrackingListItemModelTypeCard)) {
        return compareNullableValues(self.hsCard, other.hsCard, @selector(isEqual:)) &&
        compareNullableValues(self.hsCardCount, other.hsCardCount, @selector(isEqualToNumber:));
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.type ^ self.hsCard.hash ^ self.hsCardCount.hash;
}

@end
