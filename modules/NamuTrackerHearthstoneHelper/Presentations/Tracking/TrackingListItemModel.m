#import "TrackingListItemModel.h"
#import <compareNullableValues.h>

@implementation TrackingListItemModel

- (instancetype)initWithHSCard:(HSCard * _Nullable)hsCard alternativeHSCard:(AlternativeHSCard * _Nullable)alternativeHSCard hsCardCount:(NSNumber *)hsCardCount {
    if (self = [self init]) {
        self->_type = TrackingListItemModelTypeCard;
        self->_hsCard = [hsCard copy];
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

    if ((self.type == TrackingListItemModelTypeCard) && (other.type == TrackingListItemModelTypeCard)) {
        return compareNullableValues(self.hsCard, other.hsCard, @selector(isEqual:)) &&
        compareNullableValues(self.alternativeHSCard, other.alternativeHSCard, @selector(isEqual:));
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

        _copy->_hsCard = [self.hsCard copyWithZone:zone];
        _copy->_alternativeHSCard = [self.alternativeHSCard copyWithZone:zone];
        _copy->_hsCardCount = [self.hsCardCount copyWithZone:zone];
    }

    return copy;
}

@end
