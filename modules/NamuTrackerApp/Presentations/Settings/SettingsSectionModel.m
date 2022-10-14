//
//  SettingsSectionModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "SettingsSectionModel.h"
#import "LocalizableService.h"

@implementation SettingsSectionModel

- (instancetype)initWithType:(SettingsSectionModelType)type {
    if (self = [super init]) {
        self->_type = type;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    SettingsSectionModel *other = (SettingsSectionModel *)object;
    
    if (![other isKindOfClass:[SettingsSectionModel class]]) {
        return NO;
    }
    
    if ((self.type == SettingsSectionModelTypeNotices) && (other.type == SettingsSectionModelTypeNotices)) {
        return YES;
    } else if ((self.type == SettingsSectionModelTypeGeneral) && (other.type == SettingsSectionModelTypeGeneral)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.type;
}

- (NSString *)headerText {
    switch (self.type) {
        case SettingsSectionModelTypeNotices:
            return [LocalizableService localizableForKey:LocalizableKeyNotices];
        case SettingsSectionModelTypeGeneral:
            return [LocalizableService localizableForKey:LocalizableKeyGeneral];
        default:
            return nil;
    }
}

- (NSString *)footerText {
    switch (self.type) {
        case SettingsSectionModelTypeGeneral: {
            NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
            NSString *buildVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
            NSString *shortVersionString = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
            return [NSString stringWithFormat:@"%@ | %@ (%@)", bundleIdentifier, buildVersion, shortVersionString];
        }
        default:
            return nil;
    }
}

@end
