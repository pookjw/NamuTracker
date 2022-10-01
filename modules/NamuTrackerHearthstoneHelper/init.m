#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <libhooker/libhooker.h>
#import <UnityFramework/UnityAppController.h>
#import "HSLogService.h"
#import "TrackingService.h"
@import Darwin;

static int (*oritinal_sysctl)(int *, u_int, void *, size_t *, void *, size_t);
static int custom_sysctl(int *arg0, u_int arg1, void *arg2, size_t *arg3, void *arg4, size_t arg5) {
    int result = oritinal_sysctl(arg0, arg1, arg2, arg3, arg4, arg5);

    if (arg0[1] == KERN_PROC) {
        struct kinfo_proc *info = (struct kinfo_proc *)arg2;
        info->kp_proc.p_flag -= (info->kp_proc.p_flag & P_TRACED);
    }
    return result;
}

static BOOL (*original_UnityAppController_application_willFinishLaunchingWithOptions)(UnityAppController *self, SEL selector, UIApplication *application, NSDictionary<UIApplicationLaunchOptionsKey, id> *launchOptions);
static BOOL custom_UnityAppController_application_willFinishLaunchingWithOptions(UnityAppController *self, SEL selector, UIApplication *application, NSDictionary<UIApplicationLaunchOptionsKey, id> *launchOptions) {
    [TrackingService.sharedInstance startObserving];
    [HSLogService.sharedInstance installCustomLogConfiguration];
    [HSLogService.sharedInstance startObserving];
    return original_UnityAppController_application_willFinishLaunchingWithOptions(self, selector, application, launchOptions);
}

__attribute__((constructor)) static void init() {
    const struct LHFunctionHook sysctlHook[1] = {{(void *)sysctl, (void **)&custom_sysctl, (void **)&oritinal_sysctl}};
    LHHookFunctions(sysctlHook, 1);

    // seems like hearthstone loads UnityFramework lazily, and libhooker cannot hook lazy framework unlike substrate. Load it immediately.
    void *handle = dlopen("./UnityFramework.framework/UnityFramework", RTLD_NOW);
    LBHookMessage(NSClassFromString(@"UnityAppController"), @selector(application:willFinishLaunchingWithOptions:), &custom_UnityAppController_application_willFinishLaunchingWithOptions, &original_UnityAppController_application_willFinishLaunchingWithOptions);
}
