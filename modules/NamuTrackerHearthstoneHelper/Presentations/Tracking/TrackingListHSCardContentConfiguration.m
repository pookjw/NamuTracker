//
//  TrackingListHSCardContentConfiguration.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/19/22.
//

#import "TrackingListHSCardContentConfiguration.h"
#import "TrackingListHSCardContentView.h"
#import "compareNullableValues.h"

@interface TrackingListHSCardContentConfiguration ()
@end

@implementation TrackingListHSCardContentConfiguration

- (instancetype)initWithHSCard:(HSCard *)hsCard hsCardCount:(nonnull NSNumber *)hsCardCount {
    if (self = [super init]) {
        self->_hsCard = [hsCard copy];
        self->_hsCardCount = [hsCardCount copy];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    TrackingListHSCardContentConfiguration *other = (TrackingListHSCardContentConfiguration *)object;
    if (![other isKindOfClass:[TrackingListHSCardContentConfiguration class]]) return NO;
    
    return compareNullableValues(self.hsCard, other.hsCard, @selector(isEqual:)) &&
    compareNullableValues(self.hsCardCount, other.hsCardCount, @selector(isEqualToNumber:));
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    id copy = [[self class] new];
    
    if (copy) {
        TrackingListHSCardContentConfiguration *_copy = (TrackingListHSCardContentConfiguration *)copy;
        _copy->_hsCard = [self.hsCard copyWithZone:zone];
        _copy->_hsCardCount = [self.hsCardCount copyWithZone:zone];
    }
    
    return copy;
}

- (nonnull __kindof UIView<UIContentView> *)makeContentView { 
    TrackingListHSCardContentView *contentView = [[TrackingListHSCardContentView alloc] initWithContentConfiguration:self];
    return contentView;
}

- (nonnull instancetype)updatedConfigurationForState:(nonnull id<UIConfigurationState>)state { 
    return self;
}

@end
