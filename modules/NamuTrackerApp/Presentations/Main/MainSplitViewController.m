//
//  MainSplitViewController.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "MainSplitViewController.h"
#import "SettingsViewController.h"
#import "checkAvailability.h"

@interface MainSplitViewController () <UINavigationControllerDelegate>
@property (strong) SettingsViewController *settingsViewController;
@end

@implementation MainSplitViewController

- (instancetype)init {
    if (self = [super initWithStyle:UISplitViewControllerStyleDoubleColumn]) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self configureSettingsViewController];
}

- (void)setViewController:(UIViewController *)vc forColumn:(UISplitViewControllerColumn)column {
    [super setViewController:vc forColumn:column];
    
    UINavigationController *navigationController = vc.navigationController;
    navigationController.delegate = self;
    navigationController.navigationBar.prefersLargeTitles = (column == UISplitViewControllerColumnPrimary);
}

- (void)setAttributes {
    self.view.backgroundColor = UIColor.clearColor;
    self.primaryBackgroundStyle = UISplitViewControllerBackgroundStyleNone;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
    
    if (checkAvailability(@"14.5")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        self.displayModeButtonVisibility = UISplitViewControllerDisplayModeButtonVisibilityNever;
#pragma clang diagnostic pop
    }
}

- (void)configureSettingsViewController {
    SettingsViewController *settingsViewController = [SettingsViewController new];
    [self setViewController:settingsViewController forColumn:UISplitViewControllerColumnPrimary];
    self.settingsViewController = settingsViewController;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        CGFloat originalAlpha = viewController.view.alpha;
        viewController.view.alpha = 0.0f;
        
        [viewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            viewController.view.alpha = originalAlpha;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            
        }];
        
        //
        
        NSUInteger index = [navigationController.viewControllers indexOfObject:viewController];
        if ((index == 0) || (index == NSNotFound)) return;
        
        UIViewController *previousViewController = navigationController.viewControllers[index - 1];
        CGFloat originalPreviousAlpha = previousViewController.view.alpha;
        
        [previousViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            previousViewController.view.alpha = 0.0f;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            previousViewController.view.alpha = originalPreviousAlpha;
        }];
    }
}

@end
