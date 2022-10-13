//
//  SceneDelegate.m
//  NamuTracker
//
//  Created by Jinwoo Kim on 9/21/22.
//

#import "SceneDelegate.h"
#import "PrerequisiteService.h"
#import "MainSplitViewController.h"

@interface SceneDelegate ()
@property (strong) PrerequisiteService *prerequisiteService;
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window = window;
    window.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f];
    [window makeKeyAndVisible];
    
    PrerequisiteService *prerequisiteService = [[PrerequisiteService alloc] initWithWindowScene:windowScene];
    self.prerequisiteService = prerequisiteService;
    if ([prerequisiteService presentAlertIfNeeded]) return;
    
    MainSplitViewController *rootViewController = [MainSplitViewController new];
    window.rootViewController = rootViewController;
}

@end
