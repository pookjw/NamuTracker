//
//  AlternativeHSCard.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import "AlternativeHSCard.h"
#import "nullSafetyHandler.h"
#import "compareNullableValues.h"

@implementation AlternativeHSCard

@dynamic cardId;
@dynamic dbfId;

- (NSComparisonResult)compare:(AlternativeHSCard *)other {
    return comparisonResultNullableValues(self.cardId, other.cardId, @selector(compare:));
}

- (void)synchronizeWithDictionary:(NSDictionary *)dictionary {
    NSString *cardId = nullSafetyHandler(dictionary[@"cardId"]);
    self.cardId = [cardId copy];

    id dbfId = nullSafetyHandler(dictionary[@"dbfId"]);
    if ([dbfId isKindOfClass:[NSNumber class]]) {
        self.dbfId = [dbfId copy];
    } else if ([dbfId isKindOfClass:[NSString class]]) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.dbfId = [numberFormatter numberFromString:dictionary[@"dbfId"]];
    }
}

@end
