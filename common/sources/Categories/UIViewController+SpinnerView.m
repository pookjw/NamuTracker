//
//  UIViewController+SpinnerView.m
//  UIViewController+SpinnerView
//
//  Created by Jinwoo Kim on 8/29/21.
//

#import "UIViewController+SpinnerView.h"
#import <objc/runtime.h>
#define ANIMATION_DURATION 0.2f

static int const _UIViewCntrollerSpinnerAssociatedKey = 0;

@interface UIViewController (SpinnerView)
@property (nonatomic) UIView * _Nullable spinnerView_containerView;
@end

@implementation UIViewController (SpinnerView)

- (void)addSpinnerView {
    if (self.spinnerView_containerView) return;
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [containerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [containerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial]];
    visualEffectView.clipsToBounds = YES;
    visualEffectView.layer.cornerRadius = 25.0f;
    visualEffectView.layer.cornerCurve = kCACornerCurveContinuous;
    [containerView addSubview:visualEffectView];
    visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [visualEffectView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [visualEffectView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [visualEffectView.widthAnchor constraintEqualToConstant:100.0f],
        [visualEffectView.heightAnchor constraintEqualToConstant:100.0f]
    ]];
    
    SpinnerView *spinnerView = [SpinnerView new];
    [visualEffectView.contentView addSubview:spinnerView];
    spinnerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [spinnerView.topAnchor constraintEqualToAnchor:visualEffectView.contentView.topAnchor constant:15.0f],
        [spinnerView.leadingAnchor constraintEqualToAnchor:visualEffectView.contentView.leadingAnchor constant:15.0f],
        [spinnerView.trailingAnchor constraintEqualToAnchor:visualEffectView.contentView.trailingAnchor constant:-15.0f],
        [spinnerView.bottomAnchor constraintEqualToAnchor:visualEffectView.contentView.bottomAnchor constant:-15.0f]
    ]];
    [spinnerView startAnimating];
    
    visualEffectView.alpha = 0;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        visualEffectView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    self.spinnerView_containerView = containerView;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
#pragma clang diagnostic pop
}

- (void)removeAllSpinnerview {
    UIView * _Nullable containerView = self.spinnerView_containerView;
    if (containerView == nil) return;
    
    self.spinnerView_containerView = nil;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        containerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [containerView removeFromSuperview];
    }];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
#pragma clang diagnostic pop
}

- (UIView *)spinnerView_containerView {
    return objc_getAssociatedObject(self, &_UIViewCntrollerSpinnerAssociatedKey);
}

- (void)setSpinnerView_containerView:(UIVisualEffectView *)spinnerView_visualEffectView {
    objc_setAssociatedObject(self, &_UIViewCntrollerSpinnerAssociatedKey, spinnerView_visualEffectView, OBJC_ASSOCIATION_RETAIN);
}

@end
