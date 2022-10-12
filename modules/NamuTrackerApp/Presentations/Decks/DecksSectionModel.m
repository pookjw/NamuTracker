//
//  DecksSectionModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import "DecksSectionModel.h"

@implementation DecksSectionModel

- (instancetype)initDecksSection {
    if (self = [super init]) {
        self->_type = DecksSectionModelTypeDecks;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    DecksSectionModel *other = (DecksSectionModel *)object;
    
    if (![other isKindOfClass:[DecksSectionModel class]]) {
        return NO;
    }
    
    if ((self.type == DecksSectionModelTypeDecks) && (other.type == DecksSectionModelTypeDecks)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.type;
}

@end
