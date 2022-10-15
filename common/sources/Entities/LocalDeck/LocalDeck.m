//
//  LocalDeck.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/14/22.
//

#import "LocalDeck.h"

@implementation LocalDeck

@dynamic selected;
@dynamic format;
@dynamic classId;
@dynamic deckCode;
@dynamic name;
@dynamic index;
@dynamic timestamp;

- (NSNumber *)isSelected {
    return [self primitiveValueForKey:@"selected"];
}

- (void)synchronizeWithHSDeck:(HSDeck *)hsDeck {
    self.deckCode = hsDeck.deckCode;
    self.format = hsDeck.format;
    self.classId = hsDeck.classId;
}

@end
