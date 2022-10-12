//
//  DecksItemModel.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DecksItemModelType) {
    DecksItemModelTypeDeck
};

@interface DecksItemModel : NSObject
@property (readonly) DecksItemModelType type;

@end

NS_ASSUME_NONNULL_END
