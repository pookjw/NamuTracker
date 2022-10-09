#import "TrackingListItemModel.h"
#import <compareNullableValues.h>

@implementation TrackingListItemModel

- (instancetype)initWithHSCard:(HSCard *)hsCard hsCardCount:(NSNumber *)hsCardCount {
    if (self = [self init]) {
        self->_type = TrackingListItemModelTypeHSCard;
        self->_hsCard = [hsCard copy];
        self.hsCardCount = hsCardCount;
    }

    return self;
}
- (instancetype)initWithAlternativeHSCard:(AlternativeHSCard *)alternativeHSCard hsCardCount:(NSNumber *)hsCardCount {
    if (self = [self init]) {
        self->_type = TrackingListItemModelTypeAlternativeHSCard;
        self->_alternativeHSCard = [alternativeHSCard copy];
        self.hsCardCount = hsCardCount;
    }

    return self;
}

- (BOOL)isEqual:(id)object {
    TrackingListItemModel *other = (TrackingListItemModel *)object;
    
    if (![other isKindOfClass:[TrackingListItemModel class]]) {
        return NO;
    }

    if ((self.type == TrackingListItemModelTypeHSCard) && (other.type == TrackingListItemModelTypeHSCard)) {
        return compareNullableValues(self.hsCard, other.hsCard, @selector(isEqual:));
    } else if ((self.type == TrackingListItemModelTypeAlternativeHSCard) && (other.type == TrackingListItemModelTypeAlternativeHSCard)) {
        return compareNullableValues(self.alternativeHSCard, other.alternativeHSCard, @selector(isEqual:));
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.type ^ self.hsCard.hash ^ self.alternativeHSCard.hash;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[self class] new];
    
    if (copy) {
        TrackingListItemModel *_copy = (TrackingListItemModel *)copy;

        _copy->_type = self.type;
        _copy->_hsCard = [self.hsCard copyWithZone:zone];
        _copy->_alternativeHSCard = [self.alternativeHSCard copyWithZone:zone];
        _copy->_hsCardCount = [self.hsCardCount copyWithZone:zone];
    }

    return copy;
}

@end
