#import <Foundation/Foundation.h>
#import <libhooker/libhooker.h>
#import <SpringBoard/SBApplicationInfo.h>
#import <NamuTracker/identifiers.h>

static NSUInteger (*original_SBApplicationInfo_backgroundStyle)(SBApplicationInfo *self, SEL selector);
static NSUInteger custom_SBApplicationInfo_backgroundStyle(SBApplicationInfo *self, SEL selector) {
    if (([self.bundleIdentifier isEqualToString:NamuTrackerIdentifierApp]) || ([self.bundleIdentifier isEqualToString:NamuTrackerIdentifierAppUserland])) {
        return 4; // like com.apple.mobilesafari
    } else {
        return original_SBApplicationInfo_backgroundStyle(self, selector);
    }
}

static BOOL (*original_SBApplicationInfo_canChangeBackgroundStyle)(SBApplicationInfo *self, SEL selector);
static BOOL custom_SBApplicationInfo_canChangeBackgroundStyle(SBApplicationInfo *self, SEL selector) {
    if (([self.bundleIdentifier isEqualToString:NamuTrackerIdentifierApp]) || ([self.bundleIdentifier isEqualToString:NamuTrackerIdentifierAppUserland])) {
        return YES; // like com.apple.mobilesafari
    } else {
        return original_SBApplicationInfo_canChangeBackgroundStyle(self, selector);
    }
}

__attribute__((constructor)) static void init() {
    LBHookMessage(NSClassFromString(@"SBApplicationInfo"), @selector(backgroundStyle), &custom_SBApplicationInfo_backgroundStyle, &original_SBApplicationInfo_backgroundStyle);
    LBHookMessage(NSClassFromString(@"SBApplicationInfo"), @selector(canChangeBackgroundStyle), &custom_SBApplicationInfo_canChangeBackgroundStyle, &original_SBApplicationInfo_canChangeBackgroundStyle);
}
