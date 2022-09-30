#import "compareNullableValues.h"
#import <objc/message.h>

BOOL compareNullableValues(id _Nullable lhs, id _Nullable rhs, SEL _Nonnull selector) {
    BOOL result;
    
    if ((lhs == nil) && (rhs == nil)) {
        result = YES;
    } else if ((lhs == nil) || (rhs == nil)) {
        result = NO;
    } else {
        result = ((BOOL (*)(id, SEL, id))objc_msgSend)(lhs, selector, rhs);
    }
    
    return result;
}

NSComparisonResult comparisonResultNullableValues(id _Nullable lhs, id _Nullable rhs, SEL _Nonnull selector) {
    NSComparisonResult result;
    
    if ((lhs == nil) && (rhs == nil)) {
        result = NSOrderedSame;
    } else if ((lhs == nil) && (rhs != nil)) {
        result = NSOrderedAscending;
    } else if ((lhs != nil) && (rhs == nil)) {
        result = NSOrderedDescending;
    } else {
        result = ((NSComparisonResult (*)(id, SEL, id))objc_msgSend)(lhs, selector, rhs);
    }
    
    return result;
}
