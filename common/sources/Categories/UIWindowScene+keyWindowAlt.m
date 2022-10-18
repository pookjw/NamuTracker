//
//  UIWindowScene+keyWindowAlt.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "UIWindowScene+keyWindowAlt.h"
#import "checkAvailability.h"

@implementation UIWindowScene (KeyWindowAlt)

- (UIWindow *)keyWindowAlt {
    if (checkAvailability(@"15.0")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        return self.keyWindow;
#pragma clang diagnostic pop
    } else {
        __block UIWindow * _Nullable result = nil;
        
        [self.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isKeyWindow) {
                result = obj;
                *stop = YES;
            }
        }];
        
        return result;
    }
}

@end
