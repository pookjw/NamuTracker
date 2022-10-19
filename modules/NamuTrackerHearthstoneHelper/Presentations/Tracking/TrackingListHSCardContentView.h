//
//  TrackingListHSCardContentView.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/19/22.
//

#import <UIKit/UIKit.h>
#import "TrackingListHSCardContentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackingListHSCardContentView : UIView <UIContentView>
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithContentConfiguration:(TrackingListHSCardContentConfiguration *)contentConfiguration NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
