#import "PassthroughView.h"

@implementation PassthroughView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL __block pointInside = NO;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(obj.frame, point) && (obj.isUserInteractionEnabled)) {
            pointInside = YES;
            *stop = YES;
        }
    }];
    
    return pointInside;
}

@end
