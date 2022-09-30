#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <libhooker/libhooker.h>
#import <UnityFramework/UnityAppController.h>
#import "HSLogService.h"
#import "TrackingService.h"

static BOOL (*original_UnityAppController_application_willFinishLaunchingWithOptions)(UnityAppController *self, SEL selector, UIApplication *application, NSDictionary<UIApplicationLaunchOptionsKey, id> *launchOptions);
static BOOL custom_UnityAppController_application_willFinishLaunchingWithOptions(UnityAppController *self, SEL selector, UIApplication *application, NSDictionary<UIApplicationLaunchOptionsKey, id> *launchOptions) {
    [TrackingService.sharedInstance startObserving];
    [HSLogService.sharedInstance installCustomLogConfiguration];
    [HSLogService.sharedInstance startObserving];
    return original_UnityAppController_application_willFinishLaunchingWithOptions(self, selector, application, launchOptions);
}

__attribute__((constructor)) static void init() {
    // seems like hearthstone loads UnityFramework lazily, and libhooker cannot hook lazy framework unlike substrate. Load it immediately.
    void *handle = dlopen("./UnityFramework.framework/UnityFramework", RTLD_NOW);
    LBHookMessage(NSClassFromString(@"UnityAppController"), @selector(application:willFinishLaunchingWithOptions:), &custom_UnityAppController_application_willFinishLaunchingWithOptions, &original_UnityAppController_application_willFinishLaunchingWithOptions);
}
