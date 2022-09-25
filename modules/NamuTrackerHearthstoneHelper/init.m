#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <libhooker/libhooker.h>
#import <UnityFramework/UnityAppController.h>

static void configure_log() {
        NSString *configStr = @"[LoadingScreen]\n\
LogLevel=1\n\
FilePrinting=true\n\
ConsolePrinting=true\n\
ScreenPrinting=false\n\
\n\
[Zone]\n\
LogLevel=1\n\
FilePrinting=true\n\
ConsolePrinting=true\n\
ScreenPrinting=false\n\
";

    NSData *configData = [configStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *documentURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *configURL = [[documentURL URLByAppendingPathComponent:@"log"] URLByAppendingPathExtension:@"config"];
    [configData writeToURL:configURL options:NSDataWritingAtomic error:nil];
}

static BOOL (*original_UnityAppController_application_willFinishLaunchingWithOptions)(UnityAppController *self, SEL selector, UIApplication *application, NSDictionary<UIApplicationLaunchOptionsKey, id> *launchOptions);
static BOOL custom_UnityAppController_application_willFinishLaunchingWithOptions(UnityAppController *self, SEL selector, UIApplication *application, NSDictionary<UIApplicationLaunchOptionsKey, id> *launchOptions) {
    configure_log();
    return original_UnityAppController_application_willFinishLaunchingWithOptions(self, selector, application, launchOptions);
}

__attribute__((constructor)) static void init() {
    // seems like hearthstone loads UnityFramework lazily, and libhooker cannot hook lazy framework unlike substrate. Load it immediately.
    void *handle = dlopen("./UnityFramework.framework/UnityFramework", RTLD_NOW);
    LBHookMessage(NSClassFromString(@"UnityAppController"), @selector(application:willFinishLaunchingWithOptions:), &custom_UnityAppController_application_willFinishLaunchingWithOptions, &original_UnityAppController_application_willFinishLaunchingWithOptions);
}
