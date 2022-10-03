#import "checkAvailability.h"
#import <UIKit/UIKit.h>

BOOL checkAvailability(NSString *version) {
    return ([UIDevice.currentDevice.systemVersion compare:version options:NSNumericSearch] != NSOrderedAscending);
}