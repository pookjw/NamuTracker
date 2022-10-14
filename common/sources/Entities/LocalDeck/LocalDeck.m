//
//  LocalDeck.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/14/22.
//

#import "LocalDeck.h"

@implementation LocalDeck

@dynamic hsCardsData;
@dynamic format;
@dynamic classId;
@dynamic deckCode;
@dynamic name;
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

- (void)synchronizeWithHSDeck:(HSDeck *)hsDeck {
    NSLog(@"TODO");
}

@end
