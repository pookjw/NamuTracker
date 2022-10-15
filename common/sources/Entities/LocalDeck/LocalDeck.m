//
//  LocalDeck.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/14/22.
//

#import "LocalDeck.h"

@implementation LocalDeck

@dynamic selected;
@dynamic hsCardsData;
@dynamic format;
@dynamic classId;
@dynamic deckCode;
@dynamic name;
@dynamic index;
@dynamic timestamp;

- (NSArray<HSCard *> *)hsCards {
    @synchronized (self) {
        NSError * _Nullable error = nil;
        NSArray<HSCard *> * _Nullable hsCards = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray<HSCard *> class] fromData:self.hsCardsData error:&error];
        
        if (error) {
            NSLog(@"%@", error);
            return @[];
        } else if (hsCards == nil) {
            return @[];
        }
        
        return hsCards;
    }
}

- (void)setHsCards:(NSArray<HSCard *> *)hsCards {
    @synchronized (self) {
        NSError * _Nullable error = nil;
        
        NSData *hsCardsData = [NSKeyedArchiver archivedDataWithRootObject:hsCards requiringSecureCoding:YES error:&error];
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        
        self.hsCardsData = hsCardsData;
    }
}

- (NSNumber *)isSelected {
    return [self primitiveValueForKey:@"selected"];
}

- (void)synchronizeWithHSDeck:(HSDeck *)hsDeck {
    self.deckCode = hsDeck.deckCode;
    self.format = hsDeck.format;
    self.classId = hsDeck.classId;
    self.hsCards = hsDeck.hsCards;
}

@end
