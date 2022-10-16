//
//  SpinnerView.m
//  StoneNamu
//
//  Created by Jinwoo Kim on 11/8/21.
//

#import "SpinnerView.h"
#import <QuartzCore/QuartzCore.h>

#define PROGRESS_CIRCULAR_ANIMATION_KEY @"rotation"

@interface SpinnerView ()
@property (retain) UIView *contentView;
@property (retain) UIView *baseCircularView;
@property (retain) CAShapeLayer *baseCircularPathLayer;
@property (retain) UIView *progressCircularView;
@property (retain) CAShapeLayer *progressCircularLayer;
@property (retain) CABasicAnimation *progressCircularAnimation;
@end

@implementation SpinnerView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setAttributes];
        [self configureContentView];
        [self configureBaseCircularView];
        [self configureProgressCircularView];
        [self updateTintColors];
    }
    
    return self;
}

- (void)dealloc {
    [self.baseCircularView removeObserver:self forKeyPath:@"bounds"];
    [self.progressCircularView removeObserver:self forKeyPath:@"bounds"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self redrawBaseCircularPath];
    [self redrawProgressCircularPath];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateTintColors];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:self.baseCircularView] && [keyPath isEqualToString:@"bounds"]) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self redrawBaseCircularPath];
        }];
    } else if ([object isEqual:self.progressCircularView] && [keyPath isEqualToString:@"bounds"]) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self redrawProgressCircularPath];
        }];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)startAnimating {
    [self layoutIfNeeded];
    
    if (![self.progressCircularLayer.animationKeys containsObject:PROGRESS_CIRCULAR_ANIMATION_KEY]) {
        [self.progressCircularLayer addAnimation:self.progressCircularAnimation forKey:PROGRESS_CIRCULAR_ANIMATION_KEY];
    }
}

- (void)stopAnimating {
    [self.progressCircularLayer removeAnimationForKey:PROGRESS_CIRCULAR_ANIMATION_KEY];
}

- (void)setAttributes {
    self.backgroundColor = UIColor.clearColor;
}

- (void)configureContentView {
    UIView *contentView = [UIView new];
    
    [self addSubview:contentView];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [contentView.topAnchor constraintEqualToAnchor:self.topAnchor];
    topConstraint.priority = UILayoutPriorityDefaultLow;
    
    NSLayoutConstraint *leadingConstraint = [contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    leadingConstraint.priority = UILayoutPriorityDefaultLow;
    
    NSLayoutConstraint *trailingConstraint = [contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor];
    trailingConstraint.priority = UILayoutPriorityDefaultLow;
    
    NSLayoutConstraint *bottomConstraint = [contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor];
    bottomConstraint.priority = UILayoutPriorityDefaultLow;
    
    NSLayoutConstraint *widthConstraint = [contentView.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor];
    widthConstraint.priority = UILayoutPriorityDefaultHigh;
    
    NSLayoutConstraint *heightConstraint = [contentView.heightAnchor constraintLessThanOrEqualToAnchor:self.heightAnchor];
    heightConstraint.priority = UILayoutPriorityDefaultHigh;
    
    NSLayoutConstraint *centerXConstraint = [contentView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor];
    centerXConstraint.priority = UILayoutPriorityRequired;
    
    NSLayoutConstraint *centerYConstraint = [contentView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor];
    centerYConstraint.priority = UILayoutPriorityRequired;
    
    NSLayoutConstraint *aspectConstraint = [NSLayoutConstraint constraintWithItem:contentView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:contentView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
    aspectConstraint.priority = UILayoutPriorityRequired;
    
    [NSLayoutConstraint activateConstraints:@[
        topConstraint,
        leadingConstraint,
        trailingConstraint,
        bottomConstraint,
        widthConstraint,
        heightConstraint,
        centerXConstraint,
        centerYConstraint,
        aspectConstraint
    ]];
    
    contentView.backgroundColor = UIColor.clearColor;
    
    self.contentView = contentView;
}

- (void)configureBaseCircularView {
    UIView *baseCircularView = [UIView new];
    
    [self.contentView addSubview:baseCircularView];
    baseCircularView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //
    
    [NSLayoutConstraint activateConstraints:@[
        [baseCircularView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [baseCircularView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [baseCircularView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [baseCircularView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor]
    ]];
    
    //
    
    [baseCircularView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
    
    //
    
    baseCircularView.backgroundColor = UIColor.clearColor;
    
    CAShapeLayer *baseCircularPathLayer = [CAShapeLayer new];
    self.baseCircularPathLayer = baseCircularPathLayer;
    baseCircularPathLayer.fillColor = UIColor.clearColor.CGColor;
    
    [baseCircularView.layer addSublayer:baseCircularPathLayer];
    
    self.baseCircularView = baseCircularView;
}

- (void)redrawBaseCircularPath {
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGFloat lineWidth = (self.baseCircularView.bounds.size.height / 10.0f);
    
    CGPathAddArc(mutablePath,
                 nil,
                 CGRectGetMidX(self.baseCircularView.bounds),
                 CGRectGetMidY(self.baseCircularView.bounds),
                 (CGRectGetMidY(self.baseCircularView.bounds) - (lineWidth / 2.0f)),
                 (M_PI / 2.0f),
                 -(M_PI / 2.0f),
                 YES);
    CGPathAddArc(mutablePath,
                 nil,
                 CGRectGetMidX(self.baseCircularView.bounds),
                 CGRectGetMidY(self.baseCircularView.bounds),
                 (CGRectGetMidY(self.baseCircularView.bounds) - (lineWidth / 2.0f)),
                 -(M_PI / 2.0f),
                 (M_PI / 2.0f),
                 YES);
    
    CGPathCloseSubpath(mutablePath);
    
    CGPathRef path = CGPathCreateCopy(mutablePath);
    CGPathRelease(mutablePath);
    
    self.baseCircularPathLayer.path = path;
    CGPathRelease(path);
    
    self.baseCircularPathLayer.lineWidth = lineWidth;
}

- (void)configureProgressCircularView {
    UIView *progressCircularView = [UIView new];

    [self.contentView addSubview:progressCircularView];
    progressCircularView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //
    
    [NSLayoutConstraint activateConstraints:@[
        [progressCircularView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [progressCircularView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [progressCircularView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [progressCircularView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor]
    ]];
    
    //
    
    progressCircularView.backgroundColor = UIColor.clearColor;
    
    CAShapeLayer *progressCircularLayer = [CAShapeLayer new];
    progressCircularLayer.backgroundColor = UIColor.clearColor.CGColor;
    progressCircularLayer.strokeColor = UIColor.clearColor.CGColor;
    
    [progressCircularView.layer addSublayer:progressCircularLayer];
    self.progressCircularLayer = progressCircularLayer;
    
    //
    
    CABasicAnimation *progressCircularAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    self.progressCircularAnimation = progressCircularAnimation;
    
    progressCircularAnimation.removedOnCompletion = NO;
    progressCircularAnimation.duration = 1.0f;
    progressCircularAnimation.repeatCount = INFINITY;
    progressCircularAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    progressCircularAnimation.toValue = [NSNumber numberWithFloat:(M_PI * 2.0)];
    
    //
    
    [progressCircularView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
    
    //
    
    self.progressCircularView = progressCircularView;
}

- (void)redrawProgressCircularPath {
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGFloat lineWidth = CGRectGetMaxY(self.progressCircularView.bounds) / 10.0f;
    CGFloat degree = M_PI * (1.0f / 2.0f);
    
    CGPathAddArc(mutablePath,
                 nil,
                 0.0f,
                 0.0f,
                 CGRectGetMidY(self.progressCircularView.bounds),
                 (-(M_PI * (1.0f / 2.0f))),
                 (-(M_PI * (1.0f / 2.0f)) + degree),
                 NO);
    CGPathAddArc(mutablePath,
                 nil,
                 0.0f,
                 0.0f,
                 (CGRectGetMidY(self.progressCircularView.bounds) - lineWidth),
                 (-(M_PI * (1.0f / 2.0f)) + degree),
                 (-(M_PI * (1.0f / 2.0f))),
                 YES);
    
    CGPathCloseSubpath(mutablePath);
    
    CGPathRef path = CGPathCreateCopy(mutablePath);
    CGPathRelease(mutablePath);
    
    self.progressCircularLayer.path = path;
    CGPathRelease(path);
    
    //
    
    // https://stackoverflow.com/a/226761
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey: kCATransactionDisableActions];
    self.progressCircularLayer.position = CGPointMake(CGRectGetMidX(self.progressCircularView.bounds),
                                                      CGRectGetMidY(self.progressCircularView.bounds));
    [CATransaction commit];
}

- (void)updateTintColors {
    BOOL isDarkMode = (self.traitCollection.userInterfaceStyle != UIUserInterfaceStyleLight);
    
    if (isDarkMode) {
        self.baseCircularPathLayer.strokeColor = [UIColor.whiteColor colorWithAlphaComponent:0.1f].CGColor;
        self.progressCircularLayer.fillColor = UIColor.whiteColor.CGColor;
    } else {
        self.baseCircularPathLayer.strokeColor = [UIColor.blackColor colorWithAlphaComponent:0.1f].CGColor;
        self.progressCircularLayer.fillColor = UIColor.blackColor.CGColor;
    }
}

@end
