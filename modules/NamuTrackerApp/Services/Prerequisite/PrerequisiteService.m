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
#import <objc/message.h>

@interface PrerequisiteService ()
@property (nonatomic, readonly) BOOL isHelperInstalled;
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
    } else if (![self isHelperInstalled]) {
        [self presentAlertWithTitle:[LocalizableService localizableForKey:LocalizableKeyError] message:[LocalizableService localizableForKey:LocalizableKeyNamuTrackerHearthstoneHelperIsNotInstalled]];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isHelperInstalled {
    return [NSFileManager.defaultManager fileExistsAtPath:@"/usr/lib/TweakInject/NamuTrackerHearthstoneHelper.dylib" isDirectory:NULL];
}

- (BOOL)isHearthstoneInstalled {
    id defaultWorkspace = ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"LSApplicationWorkspace"), NSSelectorFromString(@"defaultWorkspace"));
    NSArray *allApplications = ((NSArray *(*)(id, SEL))objc_msgSend)(defaultWorkspace, NSSelectorFromString(@"allApplications")); // NSArray<LSApplicationProxy *>
    
    BOOL __block isHearthstoneInstalled = NO;
    
    [allApplications enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *bundleIdentifier = ((NSString *(*)(id, SEL))objc_msgSend)(obj, NSSelectorFromString(@"un_applicationBundleIdentifier"));
        BOOL isInstalled = ((BOOL (*)(id, SEL))objc_msgSend)(obj, NSSelectorFromString(@"isInstalled"));
        
        if (([@"com.blizzard.wtcg.hearthstone" isEqualToString:bundleIdentifier]) && (isInstalled)) {
            isHearthstoneInstalled = YES;
            *stop = YES;
        }
    }];
    
    return isHearthstoneInstalled;
}

- (void)presentAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIWindow * _Nullable keyWindow = self.windowScene.keyWindowAlt;
    if (keyWindow == nil) return;
    
    UIViewController * _Nullable rootViewController = keyWindow.rootViewController;
    if (rootViewController == nil) {
        UIViewController *_rootViewController = [UIViewController new];
        _rootViewController.view.backgroundColor = UIColor.clearColor;
        keyWindow.rootViewController = _rootViewController;
        rootViewController = _rootViewController;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:[LocalizableService localizableForKey:LocalizableKeyDone] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIApplication.sharedApplication suspend];
    }];
    
    [alert addAction:doneAction];
    
    [rootViewController presentViewController:alert animated:YES completion:^{
        
    }];
}

@end
