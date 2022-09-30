#import "AlternativeHSCard.h"
#import "NSObject+propertiesDictionary.h"
#import <compareNullableValues.h>

@implementation AlternativeHSCard

- (instancetype)initWithCardId:(NSString *)cardId dbfId:(NSUInteger)dbfId name:(NSString *)name cost:(NSUInteger)cost {
    if (self = [self init]) {
        self->_objectVersion = 0;

        self->_cardId = [cardId copy];
        self->_dbfId = dbfId;
        self->_name = [name copy];
        self->_cost = cost;
    }

    return self;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary {
    NSString *cardId = dictionary[@"cardId"];

    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSUInteger dbfId = [[numberFormatter numberFromString:dictionary[@"dbfId"]] unsignedIntegerValue];
    NSString *name = dictionary[@"name"];
    NSUInteger cost = [(NSNumber *)dictionary[@"cost"] unsignedIntegerValue];

    AlternativeHSCard *object = [[AlternativeHSCard alloc] initWithCardId:cardId dbfId:dbfId name:name cost:cost];
    return object;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", self.propertiesDictionary];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AlternativeHSCard class]]) {
        return NO;
    }

    AlternativeHSCard *other = (AlternativeHSCard *)object;
    return compareNullableValues(self.cardId, other.cardId, @selector(isEqualToString:));
}

- (NSComparisonResult)compare:(AlternativeHSCard *)other {
    return comparisonResultNullableValues(self.name, other.name, @selector(compare:));
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[self class] new];
    
    if (copy) {
        AlternativeHSCard *_copy = (AlternativeHSCard *)copy;
        _copy->_cardId = [self.cardId copyWithZone:zone];
        _copy->_dbfId = self.dbfId;
        _copy->_name = [self.name copyWithZone:zone];
        _copy->_cost = self.cost;
    }

    return copy;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [self init];
    
    if (self) {
        // NSUInteger objectVersion = [coder decodeIntegerForKey:@"objectVersion"];

        self->_objectVersion = 0;

        self->_cardId = [[coder decodeObjectOfClass:[NSString class] forKey:@"cardId"] copy];
        self->_dbfId = [coder decodeIntegerForKey:@"dbfId"];
        self->_name = [[coder decodeObjectOfClass:[NSString class] forKey:@"name"] copy];
        self->_cost = [coder decodeIntegerForKey:@"cost"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.objectVersion forKey:@"objectVersion"];

    [coder encodeObject:self.cardId forKey:@"cardId"];
    [coder encodeInteger:self.dbfId forKey:@"dbfId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.cost forKey:@"cost"];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end