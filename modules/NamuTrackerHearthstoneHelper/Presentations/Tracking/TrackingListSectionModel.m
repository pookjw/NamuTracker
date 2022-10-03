#import "TrackingListSectionModel.h"

@implementation TrackingListSectionModel

- (instancetype)initCardsSection {
    if (self = [self init]) {
        self->_type = TrackingListSectionModelTypeCards;
    }

    return self;
}

- (BOOL)isEqual:(id)object {
    TrackingListSectionModel *other = (TrackingListSectionModel *)object;
    
    if (![other isKindOfClass:[TrackingListSectionModel class]]) {
        return NO;
    }
    
    if ((self.type == TrackingListSectionModelTypeCards) && (other.type == TrackingListSectionModelTypeCards)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.type;
}

@end
