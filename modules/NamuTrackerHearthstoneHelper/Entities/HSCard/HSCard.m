// #import "HSCard.h"
// #import <compareNullableValues.h>

// @implementation HSCard

// - (BOOL)isEqual:(id)object {
//     if (![object isKindOfClass:[HSCard class]]) {
//         return NO;
//     }
    
//     HSCard *other = (HSCard *)object;
//     return (self.cardId == other.cardId) && (compareNullableValues(self.slug, other.slug, @selector(isEqualToString:)));
// }

// - (NSComparisonResult)compare:(HSCard *)other {
//     if (self.manaCost < other.manaCost) {
//         return NSOrderedAscending;
//     } else if (self.manaCost > other.manaCost) {
//         return NSOrderedDescending;
//     } else {
//         NSComparisonResult result = comparisonResultNullableValues(self.name, other.name, @selector(compare:));

//         if (result == NSOrderedSame) {
//             return comparisonResultNullableValues(self.cardId, other.cardId, @selector(compare:));
//         } else {
//             return result;
//         }
//     }
// }

// - (NSUInteger)hash {
//     return self.cardId ^ self.slug.hash;
// }

// + (NSSet<Class> *)unarchvingClasses {
//     NSSet *objectClasses = [NSSet setWithArray:@[NSNumber.class, NSArray.class, NSString.class, NSURL.class, HSCard.class]];
//     return objectClasses;
// }

// #pragma mark - NSCopying

// @end
