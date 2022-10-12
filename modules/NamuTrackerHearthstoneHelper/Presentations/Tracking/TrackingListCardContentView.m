#import "TrackingListCardContentView.h"
#import "TrackingListCardContentConfiguration.h"
#import "checkAvailability.h"

@interface TrackingListCardContentView ()
@property (readonly, nonatomic) TrackingListCardContentConfiguration *contentConfiguration;
@property (strong) UIVisualEffectView *vibrancyView;
@property (strong) UIView *manaCostContainerView;
@property (strong) UILabel *manaCostLabel;
@property (strong) NSLayoutConstraint *manaCostContainerViewWidthLayout;
@property (strong) UIView *nameContainerView;
@property (strong) UILabel *nameLabel;
@property (strong) UIView *countContainerView;
@property (strong) UILabel *countLabel;
@end

@implementation TrackingListCardContentView

@synthesize configuration = _configuration;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureVibrancyView];
        [self configureManaCostContainerView];
        [self configureManaCostLabel];
        [self configureNameContainerView];
        [self configureNameLabel];
        [self configureCountContainerView];
        [self configureCountLabel];
        [self setAttributes];
        [self updateManaCost];
    }

    return self;
}

- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
    BOOL supportsConfiguration;

    if (checkAvailability(@"16.0")) {
        supportsConfiguration = YES;
    } else {
        supportsConfiguration = [self supportsConfiguration:configuration];
    }

    if (!supportsConfiguration) return;

    //

    self->_configuration = [(NSObject<NSCopying> *)configuration copy];

    [self updateManaCost];
}

// iOS 16.0+
- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    if ([configuration isKindOfClass:[TrackingListCardContentConfiguration class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (TrackingListCardContentConfiguration *)contentConfiguration {
    return self.configuration;
}

- (void)configureVibrancyView {
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark] style:UIVibrancyEffectStyleLabel];
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];

    [self addSubview:vibrancyView];

    vibrancyView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [vibrancyView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [vibrancyView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [vibrancyView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [vibrancyView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];

    self.vibrancyView = vibrancyView;
}

- (void)configureManaCostContainerView {
    UIView *manaCostContainerView = [UIView new];
    manaCostContainerView.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.5f];

    [self.vibrancyView.contentView addSubview: manaCostContainerView];

    manaCostContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *manaCostContainerViewWidthLayout = [manaCostContainerView.widthAnchor constraintEqualToConstant:0.0f];

    [NSLayoutConstraint activateConstraints:@[
        [manaCostContainerView.topAnchor constraintEqualToAnchor:self.vibrancyView.contentView.topAnchor],
        [manaCostContainerView.leadingAnchor constraintEqualToAnchor:self.vibrancyView.contentView.leadingAnchor],
        [manaCostContainerView.bottomAnchor constraintEqualToAnchor:self.vibrancyView.contentView.bottomAnchor],
        manaCostContainerViewWidthLayout
    ]];

    self.manaCostContainerView = manaCostContainerView;
    self.manaCostContainerViewWidthLayout = manaCostContainerViewWidthLayout;
}

- (void)configureManaCostLabel {
    UILabel *manaCostLabel = [UILabel new];
    manaCostLabel.backgroundColor = UIColor.clearColor;
    manaCostLabel.textColor = UIColor.whiteColor;
    manaCostLabel.adjustsFontForContentSizeCategory = YES;
    manaCostLabel.adjustsFontSizeToFitWidth = YES;
    manaCostLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    manaCostLabel.textAlignment = NSTextAlignmentCenter;

    [self.manaCostContainerView addSubview:manaCostLabel];

    manaCostLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [manaCostLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.manaCostContainerView.topAnchor constant:10.0f],
        [manaCostLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.manaCostContainerView.leadingAnchor constant:10.0f],
        [manaCostLabel.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.manaCostContainerView.trailingAnchor constant:-10.0f],
        [manaCostLabel.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.manaCostContainerView.bottomAnchor constant:-10.0f],
        [manaCostLabel.centerXAnchor constraintEqualToAnchor:self.manaCostContainerView.centerXAnchor],
        [manaCostLabel.centerYAnchor constraintEqualToAnchor:self.manaCostContainerView.centerYAnchor]
    ]];

    self.manaCostLabel = manaCostLabel;
}

- (void)configureNameContainerView {

}

- (void)configureNameLabel {

}

- (void)configureCountContainerView {

}

- (void)configureCountLabel {

}

- (void)setAttributes {

}

- (void)updateManaCost {
    NSString *string = @"99";
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: self.manaCostLabel.font}
                                       context:nil];
    CGFloat margin = 10.0f;
    CGFloat width = ceilf(rect.size.width + margin);
    self.manaCostContainerViewWidthLayout.constant = width;
}

@end
