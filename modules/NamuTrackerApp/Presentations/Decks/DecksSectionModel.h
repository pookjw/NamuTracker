//
//  DecksSectionModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DecksSectionModelType) {
    DecksSectionModelTypeDecks
};

@interface DecksSectionModel : NSObject
@property (readonly) DecksSectionModelType type;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initDecksSection;
@end

NS_ASSUME_NONNULL_END
