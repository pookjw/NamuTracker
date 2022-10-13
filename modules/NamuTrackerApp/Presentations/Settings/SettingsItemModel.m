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
    
    if ((self.type == SettingsItemModelTypeUserlandNotice) && (other.type == SettingsItemModelTypeUserlandNotice)) {
        return YES;
    } else if ((self.type == SettingsItemModelTypeMockModeNotice) && (other.type == SettingsItemModelTypeMockModeNotice)) {
        return YES;
    } else if ((self.type == SettingsItemModelTypeDecks) && (other.type == SettingsItemModelTypeDecks)) {
        return YES;
    } else {
        return NO;
    }
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
        default:
            return nil;
    }
}

- (UIImage *)image {
    switch (self.type) {
        case SettingsItemModelTypeDecks:
            return [UIImage systemImageNamed:@"books.vertical"];
        default:
            return nil;
    }
}

- (NSArray<UICellAccessory *> *)accessories {
    switch (self.type) {
        case SettingsItemModelTypeDecks:
            return @[[UICellAccessoryDisclosureIndicator new]];
        default:
            return [NSArray<UICellAccessory *> new];
    }
}

@end
