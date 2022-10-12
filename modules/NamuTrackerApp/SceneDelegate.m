//
//  SceneDelegate.m
//  NamuTracker
//
//  Created by Jinwoo Kim on 9/21/22.
//

#import "SceneDelegate.h"
#import "DecksViewController.h"
#import "LocalizableService.h"
#import "UIApplication+Private.h"

@interface SceneDelegate ()
@property (readonly) BOOL needsHSHelperAlert;
@property BOOL didSuspend;
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    window.backgroundColor = UIColor.clearColor;
    
    if (self.needsHSHelperAlert) {
        UIViewController *viewController = [UIViewController new];
        viewController.view.backgroundColor = UIColor.systemBackgroundColor;
        window.rootViewController = viewController;
        [window makeKeyAndVisible];
        [self presentHSHelperAlert:viewController];
    } else {
        DecksViewController *viewController = [DecksViewController new];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.navigationBar.prefersLargeTitles = YES;
        window.rootViewController = navigationController;
        [window makeKeyAndVisible];
    }
    
    self.window = window;
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    if (self.didSuspend) exit(0);
}

- (BOOL)needsHSHelperAlert {
    return ![NSFileManager.defaultManager fileExistsAtPath:@"/usr/lib/TweakInject/NamuTrackerHearthstoneHelper.dylib" isDirectory:NULL];
}

- (void)presentHSHelperAlert:(UIViewController *)viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[LocalizableService localizableForKey:LocalizableKeyError]
                                                                   message:[LocalizableService localizableForKey:LocalizableKeyNamuTrackerHearthstoneHelperIsNotInstalled]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:[LocalizableService localizableForKey:LocalizableKeyDone]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        self.didSuspend = YES;
        [UIApplication.sharedApplication suspend];
    }];
    
    [alert addAction:doneAction];
    [viewController presentViewController:alert animated:YES completion:^{
        
    }];
}

@end
