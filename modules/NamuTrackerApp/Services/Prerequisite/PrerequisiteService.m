//
//  PrerequisiteService.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "PrerequisiteService.h"
#import "checkAvailability.h"
#import "UIWindowScene+keyWindowAlt.h"
#import "isMockMode.h"
#import "LocalizableService.h"
#import "UIApplication+Private.h"
#import "LSApplicationWorkspace.h"
#import <objc/message.h>
#import <StoreKit/StoreKit.h>

@interface PrerequisiteService () <SKStoreProductViewControllerDelegate>
@property (readonly, nonatomic) BOOL isHelperInstalled;
@property (readonly, nonatomic) BOOL isHearthstoneInstalled;
@property (readonly, nonatomic) UIViewController * _Nullable rootViewController;
@property (weak) UIWindowScene * _Nullable windowScene;
@end

@implementation PrerequisiteService

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene {
    if (self = [super init]) {
        self.windowScene = windowScene;
    }
    
    return self;
}

- (BOOL)presentAlertIfNeeded {
    if (isMockMode()) {
        return NO;
    } else if (!self.isHelperInstalled) {
        [self presentHelperIsNotInstalledAlert];
        return YES;
    } else if (!self.isHearthstoneInstalled) {
        [self presentHearthstoneIsNotInstalledAlert];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isHelperInstalled {
    return [NSFileManager.defaultManager fileExistsAtPath:@"/usr/lib/TweakInject/NamuTrackerHearthstoneHelper.dylib" isDirectory:NULL];
}

- (BOOL)isHearthstoneInstalled {
    LSApplicationWorkspace * defaultWorkspace = [NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace];
    NSArray<LSApplicationProxy *> *allApplications = [defaultWorkspace allApplications];
    
    __block BOOL isHearthstoneInstalled = NO;
    
    [allApplications enumerateObjectsUsingBlock:^(LSApplicationProxy * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *bundleIdentifier = [obj un_applicationBundleIdentifier];
        BOOL isInstalled = obj.isInstalled;
        
        if (([@"com.blizzard.wtcg.hearthstone" isEqualToString:bundleIdentifier]) && (isInstalled)) {
            isHearthstoneInstalled = YES;
            *stop = YES;
        }
    }];
    
    return isHearthstoneInstalled;
}

- (UIViewController *)rootViewController {
    UIWindow * _Nullable keyWindow = self.windowScene.keyWindowAlt;
    if (keyWindow == nil) return nil;
    
    if (keyWindow.rootViewController) {
        return keyWindow.rootViewController;
    } else {
        UIViewController *rootViewController = [UIViewController new];
        rootViewController.view.backgroundColor = UIColor.clearColor;
        keyWindow.rootViewController = rootViewController;
        return rootViewController;
    }
}

- (void)presentHelperIsNotInstalledAlert {
    UIViewController * _Nullable rootViewController = self.rootViewController;
    if (rootViewController == nil) return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[LocalizableService localizableForKey:LocalizableKeyError]
                                                                   message:[LocalizableService localizableForKey:LocalizableKeyNamuTrackerHearthstoneHelperIsNotInstalled]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:[LocalizableService localizableForKey:LocalizableKeyExit]
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf suspend];
    }];
    
    [alert addAction:exitAction];
    
    [rootViewController presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)presentHearthstoneIsNotInstalledAlert {
    UIViewController * _Nullable rootViewController = self.rootViewController;
    if (rootViewController == nil) return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[LocalizableService localizableForKey:LocalizableKeyError]
                                                                   message:[LocalizableService localizableForKey:LocalizableKeyHearhstoneIsNotInstalled]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *storeAction = [UIAlertAction actionWithTitle:[LocalizableService localizableForKey:LocalizableKeyOpenTheAppStore]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf presentHearthstoneProduct];
    }];
    
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:[LocalizableService localizableForKey:LocalizableKeyExit]
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf suspend];
    }];
    
    [alert addAction:storeAction];
    [alert addAction:exitAction];
    
    [rootViewController presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)presentHearthstoneProduct {
    UIViewController * _Nullable rootViewController = self.rootViewController;
    if (rootViewController == nil) return;
    
    SKStoreProductViewController *productViewController = [SKStoreProductViewController new];
    productViewController.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    
    [rootViewController presentViewController:productViewController animated:YES completion:^{
        [productViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: @"625257520"}
                                         completionBlock:^(BOOL result, NSError * _Nullable error) {
            if ((error) || (!result)) {
                [NSOperationQueue.mainQueue addOperationWithBlock:^{
                    NSURL *url = [NSURL URLWithString:@"https://apps.apple.com/app/id625257520"];
                    [weakSelf.windowScene openURL:url options:nil completionHandler:^(BOOL success) {
                        [NSOperationQueue.mainQueue addOperationWithBlock:^{
                            NSURL *url = [NSURL URLWithString:@"https://apps.apple.com/app/id625257520"];
                            [weakSelf.windowScene openURL:url options:nil completionHandler:^(BOOL success) {
                                [weakSelf suspend];
                            }];
                        }];
                    }];
                }];
            }
        }];
    }];
}

- (void)suspend {
    [UIApplication.sharedApplication suspend];
    exit(0);
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self suspend];
}

@end
