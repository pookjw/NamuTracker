#import "TrackingListSectionModel.h"

@implementation TrackingListSectionModel

- (instancetype)initWithType:(TrackingListSectionModelType)type {
    if (self = [super init]) {
        self->_type = type;
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
