#import "HSDeck.h"
#import "NSObject+propertiesDictionary.h"
#import "compareNullableValues.h"
#import "nullSafetyHandler.h"

@implementation HSDeck

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self->_deckCode = [nullSafetyHandler(dictionary[@"deckCode"]) copy];
        self->_version = [nullSafetyHandler(dictionary[@"version"]) copy];
        self->_format = [nullSafetyHandler(dictionary[@"format"]) copy];

        NSDictionary * _Nullable classDictionary = nullSafetyHandler(dictionary[@"class"]);
        self->_classId = [nullSafetyHandler(classDictionary[@"id"]) copy];

        NSArray * _Nullable cards = nullSafetyHandler(dictionary[@"cards"]);
        
        if (cards) {
            NSMutableArray<HSCard *> *hsCards = [NSMutableArray<HSCard *> new];

            [cards enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HSCard *hsCard = [[HSCard alloc] initWithDictionary:obj];
                [hsCards addObject:hsCard];
            }];

            self->_hsCards = [hsCards copy];
        } else {
            self->_hsCards = nil;
        }
    }

    return self;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", self.propertiesDictionary];
}

- (NSUInteger)hash {
    return self.deckCode.hash ^ self.version.hash ^ self.format.hash ^ self.classId.hash ^ self.hsCards.hash;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[HSDeck class]]) {
        return NO;
    }

    HSDeck *other = (HSDeck *)object;
    return compareNullableValues(self.deckCode, other.deckCode, @selector(isEqualToString:)) &&
    compareNullableValues(self.version, other.version, @selector(isEqualToNumber:)) &&
    compareNullableValues(self.format, other.format, @selector(isEqualToString:)) &&
    compareNullableValues(self.classId, other.classId, @selector(isEqualToNumber:)) &&
    compareNullableValues(self.hsCards, other.hsCards, @selector(isEqual:));
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[self class] new];
    
    if (copy) {
        HSDeck *_copy = (HSDeck *)copy;
        
        _copy->_deckCode = [self.deckCode copyWithZone:zone];
        _copy->_version = [self.version copyWithZone:zone];
        _copy->_format = [self.format copyWithZone:zone];
        _copy->_classId = [self.classId copyWithZone:zone];
        _copy->_hsCards = [self.hsCards copyWithZone:zone];
    }

    return copy;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [self init];
    
    if (self) {
        // NSUInteger objectVersion = [coder decodeIntegerForKey:@"objectVersion"];

        self->_deckCode = [[coder decodeObjectOfClass:[NSString class] forKey:@"deckCode"] copy];
        self->_version = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"version"] copy];
        self->_format = [[coder decodeObjectOfClass:[NSString class] forKey:@"format"] copy];
        self->_classId = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"classId"] copy];
        self->_hsCards = [[coder decodeObjectOfClass:[NSArray<HSCard *> class] forKey:@"hsCards"] copy];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:HSDECK_LATEST_VERSION forKey:@"objectVersion"];
    [coder encodeObject:self.deckCode forKey:@"deckCode"];
    [coder encodeObject:self.version forKey:@"version"];
    [coder encodeObject:self.format forKey:@"format"];
    [coder encodeObject:self.classId forKey:@"classId"];
    [coder encodeObject:self.hsCards forKey:@"hsCards"];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
