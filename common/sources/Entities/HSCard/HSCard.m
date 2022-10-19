#import "HSCard.h"
#import "compareNullableValues.h"
#import "nullSafetyHandler.h"
#import "NSObject+propertiesDictionary.h"

@implementation HSCard

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self->_dbfId = [nullSafetyHandler(dictionary[@"id"]) copy];
        self->_collectible = [nullSafetyHandler(dictionary[@"collectible"]) copy];
        self->_slug = [nullSafetyHandler(dictionary[@"slug"]) copy];
        self->_classId = [nullSafetyHandler(dictionary[@"classId"]) copy];
        self->_multiClassIds = [nullSafetyHandler(dictionary[@"multiClassIds"]) copy];
        self->_minionTypeId = [nullSafetyHandler(dictionary[@"spellSchoolId"]) copy];
        self->_spellSchoolId = [nullSafetyHandler(dictionary[@"spellSchoolId"]) copy];
        self->_cardTypeId = [nullSafetyHandler(dictionary[@"cardTypeId"]) copy];
        self->_cardSetId = [nullSafetyHandler(dictionary[@"cardSetId"]) copy];
        self->_rarityId = [nullSafetyHandler(dictionary[@"rarityId"]) copy];
        self->_artistName = [nullSafetyHandler(dictionary[@"artistName"]) copy];
        self->_health = [nullSafetyHandler(dictionary[@"health"]) copy];
        self->_attack = [nullSafetyHandler(dictionary[@"attack"]) copy];
        self->_manaCost = [nullSafetyHandler(dictionary[@"manaCost"]) copy];
        self->_name = [nullSafetyHandler(dictionary[@"name"]) copy];
        self->_text = [nullSafetyHandler(dictionary[@"text"]) copy];

        NSString * _Nullable image = nullSafetyHandler(dictionary[@"image"]);
        if ([image isKindOfClass:[NSString class]]) {
            self->_image = [[NSURL URLWithString:image] copy];
        }
        
        NSString *_Nullable imageGold = nullSafetyHandler(dictionary[@"imageGold"]);
        if ([imageGold isKindOfClass:[NSString class]]) {
            self->_imageGold = [[NSURL URLWithString:imageGold] copy];
        }

        self->_flavorText = [nullSafetyHandler(dictionary[@"flavorText"]) copy];

        NSString *_Nullable cropImage = nullSafetyHandler(dictionary[@"cropImage"]);
        if ([cropImage isKindOfClass:[NSString class]]) {
            self->_cropImage = [[NSURL URLWithString:cropImage] copy];
        }

        self->_childCardIds = [nullSafetyHandler(dictionary[@"childIds"]) copy];
        self->_parentCardId = [nullSafetyHandler(dictionary[@"parentId"]) copy];
    }

    return self;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", self.propertiesDictionary];
}

- (NSUInteger)hash {
    return self.dbfId.hash;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[HSCard class]]) {
        return NO;
    }
    
    HSCard *other = (HSCard *)object;
    return compareNullableValues(self.dbfId, other.dbfId, @selector(isEqual:));
}

- (NSComparisonResult)compare:(HSCard *)other {
    NSComparisonResult manaCostComparisonResult = comparisonResultNullableValues(self.manaCost, other.manaCost, @selector(compare:));

    if (manaCostComparisonResult == NSOrderedSame) {
        NSComparisonResult nameComparisonResult = comparisonResultNullableValues(self.name, other.name, @selector(compare:));

        if (nameComparisonResult == NSOrderedSame) {
            return comparisonResultNullableValues(self.dbfId, other.dbfId, @selector(compare:));
        } else {
            return nameComparisonResult;
        }
    } else {
        return manaCostComparisonResult;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[self class] new];
    
    if (copy) {
        HSCard *_copy = (HSCard *)copy;

        _copy->_dbfId = [self.dbfId copyWithZone:zone];
        _copy->_slug = [self.slug copyWithZone:zone];
        _copy->_classId = [self.classId copyWithZone:zone];
        _copy->_multiClassIds = [self.multiClassIds copyWithZone:zone];
        _copy->_minionTypeId = [self.minionTypeId copyWithZone:zone];
        _copy->_spellSchoolId = [self.spellSchoolId copyWithZone:zone];
        _copy->_cardTypeId = [self.cardTypeId copyWithZone:zone];
        _copy->_cardSetId = [self.cardSetId copyWithZone:zone];
        _copy->_rarityId = [self.rarityId copyWithZone:zone];
        _copy->_artistName = [self.artistName copyWithZone:zone];
        _copy->_health = [self.health copyWithZone:zone];
        _copy->_attack = [self.attack copyWithZone:zone];
        _copy->_manaCost = [self.manaCost copyWithZone:zone];
        _copy->_name = [self.name copyWithZone:zone];
        _copy->_text = [self.text copyWithZone:zone];
        _copy->_image = [self.image copyWithZone:zone];
        _copy->_imageGold = [self.imageGold copyWithZone:zone];
        _copy->_flavorText = [self.flavorText copyWithZone:zone];
        _copy->_cropImage = [self.cropImage copyWithZone:zone];
        _copy->_childCardIds = [self.childCardIds copyWithZone:zone];
        _copy->_parentCardId = [self.parentCardId copyWithZone:zone];
    }

    return copy;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [self init];
    
    if (self) {
        // NSUInteger objectVersion = [coder decodeIntegerForKey:@"objectVersion"];

        self->_dbfId = [coder decodeObjectOfClass:[NSNumber class] forKey:@"dbfId"];
        self->_collectible = [coder decodeObjectOfClass:[NSNumber class] forKey:@"collectible"];
        self->_slug = [[coder decodeObjectOfClass:[NSString class] forKey:@"slug"] copy];
        self->_classId = [[coder decodeObjectOfClass:[NSString class] forKey:@"classId"] copy];
        self->_multiClassIds = [[coder decodeObjectOfClass:[NSArray<NSNumber *> class] forKey:@"multiClassIds"] copy];
        self->_minionTypeId = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"minionTypeId"] copy];
        self->_spellSchoolId = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"spellSchoolId"] copy];
        self->_cardTypeId = [coder decodeObjectOfClass:[NSNumber class] forKey:@"cardTypeId"];
        self->_cardSetId = [coder decodeObjectOfClass:[NSNumber class] forKey:@"cardSetId"];
        self->_rarityId = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"rarityId"] copy];
        self->_artistName = [[coder decodeObjectOfClass:[NSString class] forKey:@"artistName"] copy];
        self->_health = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"health"] copy];
        self->_attack = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"attack"] copy];
        self->_manaCost = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"manaCost"] copy];
        self->_name = [[coder decodeObjectOfClass:[NSString class] forKey:@"name"] copy];
        self->_text = [[coder decodeObjectOfClass:[NSString class] forKey:@"text"] copy];
        self->_image = [[coder decodeObjectOfClass:[NSURL class] forKey:@"image"] copy];
        self->_imageGold = [[coder decodeObjectOfClass:[NSURL class] forKey:@"imageGold"] copy];
        self->_flavorText = [[coder decodeObjectOfClass:[NSString class] forKey:@"flavorText"] copy];
        self->_cropImage = [[coder decodeObjectOfClass:[NSURL class] forKey:@"cropImage"] copy];
        self->_childCardIds = [[coder decodeObjectOfClass:[NSArray<NSNumber *> class] forKey:@"childCardIds"] copy];
        self->_parentCardId = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"parentCardId"] copy];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:HSCARD_LATEST_VERSION forKey:@"objectVersion"];
    [coder encodeObject:self.dbfId forKey:@"dbfId"];
    [coder encodeObject:self.collectible forKey:@"collectible"];
    [coder encodeObject:self.slug forKey:@"slug"];
    [coder encodeObject:self.classId forKey:@"classId"];
    [coder encodeObject:self.multiClassIds forKey:@"multiClassIds"];
    [coder encodeObject:self.minionTypeId forKey:@"minionTypeId"];
    [coder encodeObject:self.spellSchoolId forKey:@"spellSchoolId"];
    [coder encodeObject:self.cardTypeId forKey:@"cardTypeId"];
    [coder encodeObject:self.cardSetId forKey:@"cardSetId"];
    [coder encodeObject:self.rarityId forKey:@"rarityId"];
    [coder encodeObject:self.artistName forKey:@"artistName"];
    [coder encodeObject:self.health forKey:@"health"];
    [coder encodeObject:self.attack forKey:@"attack"];
    [coder encodeObject:self.manaCost forKey:@"manaCost"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.imageGold forKey:@"imageGold"];
    [coder encodeObject:self.flavorText forKey:@"flavorText"];
    [coder encodeObject:self.cropImage forKey:@"cropImage"];
    [coder encodeObject:self.childCardIds forKey:@"childCardIds"];
    [coder encodeObject:self.parentCardId forKey:@"parentCardId"];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
