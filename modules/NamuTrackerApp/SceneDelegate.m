//
//  SceneDelegate.m
//  NamuTracker
//
//  Created by Jinwoo Kim on 9/21/22.
//

#import "SceneDelegate.h"
#import "DecksViewController.h"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    window.backgroundColor = UIColor.clearColor;
    DecksViewController *viewController = [DecksViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.prefersLargeTitles = YES;
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];
    self.window = window;

    [self presentHSHelperAlertIfNeeded];
}

- (BOOL)presentHSHelperAlertIfNeeded {
    BOOL exists = [NSFileManager.defaultManager fileExistsAtPath:@"/usr/lib/TweakInject/NamuTrackerHearthstoneHelper.dylib" isDirectory:NULL];

    if (exists) return NO;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error (TBT)"
                                                                   message:@"Seems like NamuTrackerHearthstoneHelper is not installed, or your device has not been jailbroken."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"DONE (TBT)"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];

    [alert addAction:doneAction];
    [self.window.rootViewController presentViewController:alert animated:YES completion:^{

    }];

    return YES;
}

@end
