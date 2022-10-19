//
//  TrackingListHSCardContentView.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/19/22.
//

#import "TrackingListHSCardContentView.h"
#import "UIImageView+LoadAsyncImage.h"
#import <objc/message.h>

static CGFloat const kTrackingListHSCardContentViewInset = 5.0f;

@interface TrackingListHSCardContentView ()
@property (nonatomic, readonly) TrackingListHSCardContentConfiguration *contentConfiguration;
@property (strong) UIView *manaCostContainerView;
@property (strong) UILabel *manaCostLabel;
@property (strong) NSLayoutConstraint *manaCostLabelWidthLayout;
@property (strong) UIView *countContainerView;
@property (strong) UILabel *countLabel;
@property (strong) NSLayoutConstraint *countLabelWidthLayout;
@property (strong) UIImageView *imageView;
@property (strong) CAGradientLayer *imageViewGradientLayer;
@property (strong) UIView *nameLabelContainerView;
@property (strong) UILabel *nameLabel;
@end

@implementation TrackingListHSCardContentView

@synthesize configuration = _configuration;

- (instancetype)initWithContentConfiguration:(TrackingListHSCardContentConfiguration *)contentConfiguration {
    if (self = [super initWithFrame:CGRectNull]) {        
        [self setAttributes];
        [self configureManaCostLabel];
        [self configureCountLabel];
        [self configureImageView];
        [self configureNameLabel];
        [self reorderSubviews];

        self.configuration = contentConfiguration;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateGradientLayer];
}

- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
    if ((![self supportsConfiguration:configuration]) || ([configuration isEqual:self.configuration])) return;
#pragma clang diagnostic pop
    self->_configuration = ((id (*)(id, SEL))objc_msgSend)(configuration, @selector(copy));

    //
    
    self.manaCostLabel.text = self.contentConfiguration.hsCard.manaCost.stringValue;
    self.countLabel.text = self.contentConfiguration.hsCardCount.stringValue;
    self.nameLabel.text = self.contentConfiguration.hsCard.name;
    
    NSURL *imageURL;
    if (self.contentConfiguration.hsCard.cropImage) {
        imageURL = self.contentConfiguration.hsCard.cropImage;
    } else {
        imageURL = self.contentConfiguration.hsCard.image;
    }

    // __weak typeof(self) weakSelf = self;
    [self.imageView loadAsyncImageWithURL:imageURL indicator:YES completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        // [NSOperationQueue.mainQueue addOperationWithBlock:^{
        //     [weakSelf layoutIfNeeded];
        // }];
    }];
}

- (id<UIContentConfiguration>)configuration {
    return self->_configuration;
}

- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    return [configuration isKindOfClass:[TrackingListHSCardContentConfiguration class]];
}

- (TrackingListHSCardContentConfiguration *)contentConfiguration {
    return self.configuration;
}

- (void)setAttributes {
    self.backgroundColor = nil;
}

- (void)configureManaCostLabel {
    UIView *manaCostContainerView = [UIView new];
    manaCostContainerView.backgroundColor = UIColor.systemBlueColor;
    manaCostContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *manaCostLabel = [UILabel new];
    manaCostLabel.backgroundColor = UIColor.clearColor;
    manaCostLabel.textColor = UIColor.whiteColor;
    manaCostLabel.adjustsFontForContentSizeCategory = YES;
    manaCostLabel.adjustsFontSizeToFitWidth = YES;
    manaCostLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    manaCostLabel.textAlignment = NSTextAlignmentCenter;
    manaCostLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [manaCostLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self addSubview:manaCostContainerView];
    [manaCostContainerView addSubview:manaCostLabel];
    
    CGFloat width = [self preferredWidthWithLabel:manaCostLabel];
    NSLayoutConstraint *manaCostLabelWidthLayout = [manaCostLabel.widthAnchor constraintEqualToConstant:width];
    
    [NSLayoutConstraint activateConstraints:@[
        [manaCostContainerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [manaCostContainerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [manaCostContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [manaCostLabel.topAnchor constraintEqualToAnchor:manaCostContainerView.topAnchor constant:kTrackingListHSCardContentViewInset],
        [manaCostLabel.leadingAnchor constraintEqualToAnchor:manaCostContainerView.leadingAnchor constant:kTrackingListHSCardContentViewInset],
        [manaCostLabel.trailingAnchor constraintEqualToAnchor:manaCostContainerView.trailingAnchor constant:-kTrackingListHSCardContentViewInset],
        [manaCostLabel.bottomAnchor constraintEqualToAnchor:manaCostContainerView.bottomAnchor constant:-kTrackingListHSCardContentViewInset],
        manaCostLabelWidthLayout
    ]];
    
    self.manaCostContainerView = manaCostContainerView;
    self.manaCostLabel = manaCostLabel;
    self.manaCostLabelWidthLayout = manaCostLabelWidthLayout;
}

- (void)configureCountLabel {
    UIView *countContainerView = [UIView new];
    countContainerView.backgroundColor = UIColor.systemGrayColor;
    countContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *countLabel = [UILabel new];
    countLabel.backgroundColor = UIColor.clearColor;
    countLabel.textColor = UIColor.whiteColor;
    countLabel.adjustsFontForContentSizeCategory = YES;
    countLabel.adjustsFontSizeToFitWidth = YES;
    countLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [countLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self addSubview:countContainerView];
    [countContainerView addSubview:countLabel];
    
    CGFloat width = [self preferredWidthWithLabel:countLabel];
    NSLayoutConstraint *countLabelWidthLayout = [countLabel.widthAnchor constraintEqualToConstant:width];
    
    [NSLayoutConstraint activateConstraints:@[
        [countContainerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [countContainerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [countContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [countLabel.topAnchor constraintEqualToAnchor:countContainerView.topAnchor constant:kTrackingListHSCardContentViewInset],
        [countLabel.leadingAnchor constraintEqualToAnchor:countContainerView.leadingAnchor constant:kTrackingListHSCardContentViewInset],
        [countLabel.trailingAnchor constraintEqualToAnchor:countContainerView.trailingAnchor constant:-kTrackingListHSCardContentViewInset],
        [countLabel.bottomAnchor constraintEqualToAnchor:countContainerView.bottomAnchor constant:-kTrackingListHSCardContentViewInset],
        countLabelWidthLayout
    ]];
    
    self.countContainerView = countContainerView;
    self.countLabel = countLabel;
    self.countLabelWidthLayout = countLabelWidthLayout;
}

- (void)configureImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.backgroundColor = UIColor.clearColor;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    
    [self addSubview:imageView];
    
    NSLayoutConstraint *aspectLayout = [NSLayoutConstraint constraintWithItem:imageView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:imageView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:243.0f / 64.0f
                                                                     constant:0.0f];
    
    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:self.countContainerView.leadingAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        aspectLayout
    ]];

    //
    
    CAGradientLayer *imageViewGradientLayer = [CAGradientLayer new];
    imageViewGradientLayer.colors = @[
        (id)UIColor.clearColor.CGColor,
        (id)UIColor.whiteColor.CGColor
    ];
    imageViewGradientLayer.startPoint = CGPointMake(0.3f, 0.0f);
    imageViewGradientLayer.endPoint = CGPointMake(1.0f, 0.0f);
    imageView.layer.mask = imageViewGradientLayer;
    
    self.imageView = imageView;
    self.imageViewGradientLayer = imageViewGradientLayer;
}

- (void)configureNameLabel {
    UIView *nameLabelContainerView = [UIView new];
    nameLabelContainerView.backgroundColor = UIColor.clearColor;
    nameLabelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.backgroundColor = UIColor.clearColor;
    nameLabel.textColor = UIColor.whiteColor;
    nameLabel.adjustsFontForContentSizeCategory = YES;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    nameLabel.minimumScaleFactor = 0.1f;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [nameLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self addSubview:nameLabelContainerView];
    [nameLabelContainerView addSubview:nameLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [nameLabelContainerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [nameLabelContainerView.leadingAnchor constraintEqualToAnchor:self.manaCostContainerView.trailingAnchor],
        [nameLabelContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [nameLabelContainerView.trailingAnchor constraintEqualToAnchor:self.countContainerView.leadingAnchor],
        [nameLabel.topAnchor constraintEqualToAnchor:nameLabelContainerView.topAnchor constant:kTrackingListHSCardContentViewInset],
        [nameLabel.leadingAnchor constraintEqualToAnchor:nameLabelContainerView.leadingAnchor constant:kTrackingListHSCardContentViewInset],
        [nameLabel.trailingAnchor constraintEqualToAnchor:nameLabelContainerView.trailingAnchor constant:-kTrackingListHSCardContentViewInset],
        [nameLabel.bottomAnchor constraintEqualToAnchor:nameLabelContainerView.bottomAnchor constant:-kTrackingListHSCardContentViewInset]
    ]];
    
    self.nameLabelContainerView = nameLabelContainerView;
    self.nameLabel = nameLabel;
}

- (void)reorderSubviews {
    [self bringSubviewToFront:self.manaCostContainerView];
}

- (CGFloat)preferredWidthWithLabel:(UILabel *)label {
    NSString *string = @"99";
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: label.font}
                                       context:nil];
    CGFloat margin = 10;
    CGFloat width = ceilf(rect.size.width + margin);
    
    return width;
}

- (void)updateGradientLayer {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.imageViewGradientLayer.frame = self.imageView.bounds;
    [CATransaction commit];
}

@end
