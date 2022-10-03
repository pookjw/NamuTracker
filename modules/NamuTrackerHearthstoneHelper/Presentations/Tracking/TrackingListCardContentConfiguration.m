#import "TrackingListCardContentConfiguration.h"
#import "TrackingListCardContentView.h"

@implementation TrackingListCardContentConfiguration

- (instancetype)initWithHSCard:(HSCard *)hsCard hsCardCount:(NSNumber *)hsCardCount {
    if (self = [self init]) {
        self->_hsCard = [hsCard copy];
        self->_hsCardCount = [hsCardCount copy];
    }

    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    id copy = [[self class] new];
    
    if (copy) {
        TrackingListCardContentConfiguration *_copy = (TrackingListCardContentConfiguration *)copy;

        _copy->_hsCard = [self.hsCard copyWithZone:zone];
        _copy->_hsCardCount = [self.hsCardCount copyWithZone:zone];
    }
    
    return copy;
}

- (nonnull __kindof UIView<UIContentView> *)makeContentView { 
    TrackingListCardContentView *contentView = [TrackingListCardContentView new];
    contentView.configuration = self;
    return contentView;
}

- (nonnull instancetype)updatedConfigurationForState:(nonnull id<UIConfigurationState>)state {
    return self;
}

@end
