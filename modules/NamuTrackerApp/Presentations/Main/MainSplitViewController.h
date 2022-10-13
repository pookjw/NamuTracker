//
//  MainSplitViewController.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainSplitViewController : UISplitViewController
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UISplitViewControllerStyle)style NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
