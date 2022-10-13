//
//  SceneDelegate.m
//  NamuTracker
//
//  Created by Jinwoo Kim on 9/21/22.
//

#import "SceneDelegate.h"
#import "DecksViewController.h"
#import "PrerequisiteService.h"

@interface SceneDelegate ()
@property (strong) PrerequisiteService *prerequisiteService;
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window = window;
    window.backgroundColor = UIColor.clearColor;
    [window makeKeyAndVisible];
    
    PrerequisiteService *prerequisiteService = [[PrerequisiteService alloc] initWithWindowScene:windowScene];
    self.prerequisiteService = prerequisiteService;
    if ([prerequisiteService presentAlertIfNeeded]) return;
    
    DecksViewController *viewController = [DecksViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.prefersLargeTitles = YES;
    window.rootViewController = navigationController;
}

@end
