//
//  ViewController.m
//  NamuTracker
//
//  Created by Jinwoo Kim on 9/21/22.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect style:UIVibrancyEffectStyleLabel];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [self.view addSubview:visualEffectView];
    visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [visualEffectView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [visualEffectView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [visualEffectView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [visualEffectView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    UILabel *testLabel = [UILabel new];
    testLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
#if USERLAND_MODE
    testLabel.text = @"userland!";
#elif SYSTEMLAND_MODE
    testLabel.text = @"systemland!";
#endif
    [visualEffectView.contentView addSubview:testLabel];
    testLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [testLabel.centerXAnchor constraintEqualToAnchor:visualEffectView.contentView.centerXAnchor],
        [testLabel.centerYAnchor constraintEqualToAnchor:visualEffectView.contentView.centerYAnchor]
    ]];
}

@end
