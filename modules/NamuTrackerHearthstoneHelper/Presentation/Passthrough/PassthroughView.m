#import "PassthroughView.h"

@implementation PassthroughView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL __block pointInside = NO;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!(obj.isUserInteractionEnabled)) return;
        if (CGRectContainsPoint(obj.frame, point)) {
            pointInside = YES;
            *stop = YES;
        }
    }];
    
    return pointInside;
}

@end
