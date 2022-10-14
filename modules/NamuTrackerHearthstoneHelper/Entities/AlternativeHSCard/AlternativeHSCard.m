#import "AlternativeHSCard.h"
#import "NSObject+propertiesDictionary.h"
#import "compareNullableValues.h"

@implementation AlternativeHSCard

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        NSString *cardId = dictionary[@"cardId"];

        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSUInteger dbfId = [[numberFormatter numberFromString:dictionary[@"dbfId"]] unsignedIntegerValue];

        self->_cardId = [cardId copy];
        self->_dbfId = dbfId;
    }

    return self;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", self.propertiesDictionary];
}

- (NSUInteger)hash {
    return self.cardId.hash;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AlternativeHSCard class]]) {
        return NO;
    }

    AlternativeHSCard *other = (AlternativeHSCard *)object;
    return compareNullableValues(self.cardId, other.cardId, @selector(isEqualToString:));
}

- (NSComparisonResult)compare:(AlternativeHSCard *)other {
    return comparisonResultNullableValues(self.cardId, other.cardId, @selector(compare:));
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[self class] new];
    
    if (copy) {
        AlternativeHSCard *_copy = (AlternativeHSCard *)copy;
        
        _copy->_cardId = [self.cardId copyWithZone:zone];
        _copy->_dbfId = self.dbfId;
    }

    return copy;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [self init];
    
    if (self) {
        // NSUInteger objectVersion = [coder decodeIntegerForKey:@"objectVersion"];

        self->_cardId = [[coder decodeObjectOfClass:[NSString class] forKey:@"cardId"] copy];
        self->_dbfId = [coder decodeIntegerForKey:@"dbfId"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:ALTERNATIVEHSCARD_LATEST_VERSION forKey:@"objectVersion"];

    [coder encodeObject:self.cardId forKey:@"cardId"];
    [coder encodeInteger:self.dbfId forKey:@"dbfId"];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end