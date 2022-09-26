#import "compareNullableValues.m"
#import <objc/message.h>

BOOL compareNullableValues(id _Nullable lhs, id _Nullable rhs, SEL _Nonnull selector) {
    BOOL result;
    
    if ((lhs == nil) && (rhs == nil)) {
        result = YES;
    } else if ((lhs == nil) || (rhs == nil)) {
        result = NO;
    } else {
        return (BOOL (*)(id, SEL, id)objc_msgSend)(lhs, selector, rhs);
    }
    
    return result;
}

NSComparisonResult comparisonResultNullableValues(id _Nullable lhs, id _Nullable rhs, SEL _Nonnull selector) {
    NSComparisonResult result;
    
    if ((lhs == nil) && (rhs == nil)) {
        result = NSOrderedSame;
    } else if ((lhs == nil) || (rhs == nil)) {
        result = NSOrderedSame;
    } else {
        return (BOOL (*)(NSComparisonResult, SEL, id)objc_msgSend)(lhs, selector, rhs);
    }
    
    return result;
}
