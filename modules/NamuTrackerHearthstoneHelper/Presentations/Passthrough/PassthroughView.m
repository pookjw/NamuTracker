#import "PassthroughView.h"

@implementation PassthroughView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    __block BOOL pointInside = NO;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(obj.frame, point) && (!obj.isHidden) && (obj.isUserInteractionEnabled)) {
            pointInside = YES;
            *stop = YES;
        }
    }];
    
    return pointInside;
}

@end
