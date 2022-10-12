#import "nullSafetyHandler.h"

id _Nullable (^nullSafetyHandler)(id _Nullable) = ^id _Nullable (id _Nullable object) {
    if (object == nil) {
        return nil;
    }
            
    if ([object isEqual:[NSNull null]]) {
        return nil;
    } else {
        return object;
    }
};
