#import "NSObject+propertiesDictionary.h"
#import <objc/runtime.h>

@implementation NSObject (propertiesDictionary)

- (NSDictionary *)propertiesDictionary {
    NSMutableDictionary *result = [NSMutableDictionary new];

    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertiesCount);

    for (NSUInteger i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [[NSString alloc] initWithUTF8String:property_getName(property)];
        id _Nullable value = [self valueForKey:key];

        if (value) {
            result[key] = value;
        } else {
            result[key] = [NSNull null];
        }
    }

    return [result copy];
}

@end
