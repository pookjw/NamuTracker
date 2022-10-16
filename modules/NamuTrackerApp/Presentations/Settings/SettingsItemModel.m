//
//  SettingsItemModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/13/22.
//

#import "SettingsItemModel.h"
#import "compareNullableValues.h"
#import "LocalizableService.h"

@implementation SettingsItemModel

- (instancetype)initWithType:(SettingsItemModelType)type {
    if (self = [super init]) {
        self->_type = type;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    SettingsItemModel *other = (SettingsItemModel *)object;
    
    if (![other isKindOfClass:[SettingsItemModel class]]) return NO;
    
    return (self.type == other.type);
}

- (NSUInteger)hash {
    return self.type;
}

- (NSString *)text {
    switch (self.type) {
        case SettingsItemModelTypeUserlandNotice:
            return [LocalizableService localizableForKey:LocalizableKeyRunningAsUserland];
        case SettingsItemModelTypeMockModeNotice:
            return [LocalizableService localizableForKey:LocalizableKeyEnabledMockMode];
        case SettingsItemModelTypeDecks:
            return [LocalizableService localizableForKey:LocalizableKeyDecks];
        case SettingsItemModelTypeHSAPIPreferences:
            return [LocalizableService localizableForKey:LocalizableKeyServerAndCardLanguage];
        case SettingsItemModelTypeReloadAlternativeHSCards:
            return [LocalizableService localizableForKey:LocalizableKeyReloadAlternativehscards];
        default:
            return nil;
    }
}

- (NSString *)secondaryText {
    switch (self.type) {
        case SettingsItemModelTypeUserlandNotice:
            return [LocalizableService localizableForKey:LocalizableKeyRunningAsUserlandDescription];
        case SettingsItemModelTypeMockModeNotice:
            return [LocalizableService localizableForKey:LocalizableKeyEnabledMockModeDescription];
        case SettingsItemModelTypeReloadAlternativeHSCards:
            return [LocalizableService localizableForKey:LocalizableKeyReloadAlternativehscardsDescription];
        default:
            return nil;
    }
}

- (UIImage *)image {
    switch (self.type) {
        case SettingsItemModelTypeDecks:
            return [UIImage systemImageNamed:@"books.vertical"];
        case SettingsItemModelTypeHSAPIPreferences:
            return [UIImage systemImageNamed:@"globe"];
        case SettingsItemModelTypeReloadAlternativeHSCards:
            return [UIImage systemImageNamed:@"square.and.arrow.down"];
        default:
            return nil;
    }
}

- (NSArray<UICellAccessory *> *)accessories {
    switch (self.type) {
        case SettingsItemModelTypeDecks:
            return @[[UICellAccessoryDisclosureIndicator new]];
        case SettingsItemModelTypeHSAPIPreferences:
            return @[[UICellAccessoryDisclosureIndicator new]];
        default:
            return [NSArray<UICellAccessory *> new];
    }
}

@end
