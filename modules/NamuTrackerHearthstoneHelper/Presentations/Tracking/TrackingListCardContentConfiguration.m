#import "TrackingListCardContentConfiguration.h"
#import "TrackingListCardContentView.h"

@implementation TrackingListCardContentConfiguration

- (instancetype)initWithItemModel:(TrackingListItemModel *)itemModel {
    if (self = [super init]) {
        self->_itemModel = [itemModel copy];
    }

    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    id copy = [[self class] new];
    
    if (copy) {
        TrackingListCardContentConfiguration *_copy = (TrackingListCardContentConfiguration *)copy;

        _copy->_itemModel = [self.itemModel copyWithZone:zone];
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
