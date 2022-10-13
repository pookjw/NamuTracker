//
//  PrerequisiteService.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrerequisiteService : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene NS_DESIGNATED_INITIALIZER;
- (BOOL)presentAlertIfNeeded;
@end

NS_ASSUME_NONNULL_END
