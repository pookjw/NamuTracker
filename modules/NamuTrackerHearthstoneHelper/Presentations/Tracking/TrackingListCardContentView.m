#import "TrackingListCardContentView.h"
#import "TrackingListCardContentConfiguration.h"
#import <checkAvailability.h>

@interface TrackingListCardContentView ()
@end

@implementation TrackingListCardContentView

@synthesize configuration = _configuration;

- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
    BOOL supportsConfiguration;

    if (checkAvailability(@"16.0")) {
        supportsConfiguration = YES;
    } else {
        supportsConfiguration = [self supportsConfiguration:configuration];
    }

    if (!supportsConfiguration) return;

    //

    self->_configuration = [(NSObject<NSCopying> *)configuration copy];
}

// iOS 16.0+
- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    if ([configuration isKindOfClass:[TrackingListCardContentConfiguration class]]) {
        return YES;
    } else {
        return NO;
    }
}

@end
