//
//  HSAPIPreferencesItemModel.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/16/22.
//

#import "HSAPIPreferencesItemModel.h"
#import "compareNullableValues.h"
#import "LocalizableService.h"

@implementation HSAPIPreferencesItemModel

- (instancetype)initWithHSAPIRegionHost:(HSAPIRegionHost)hsAPIRegionHost isSelected:(BOOL)isSelected {
    if (self = [super init]) {
        self->_type = HSAPIPreferencesItemModelTypeHSAPIRegionHost;
        self->_hsAPIRegionHost = @(hsAPIRegionHost);
        self.selected = isSelected;
    }
    
    return self;
}

- (instancetype)initWithHSAPILocale:(HSAPILocale)hsAPILocale isSelected:(BOOL)isSelected {
    if (self = [super init]) {
        self->_type = HSAPIPreferencesItemModelTypeHSAPILocale;
        self->_hsAPILocale = [hsAPILocale copy];
        self.selected = isSelected;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    HSAPIPreferencesItemModel *other = (HSAPIPreferencesItemModel *)object;
    
    if (![other isKindOfClass:[HSAPIPreferencesItemModel class]]) return NO;
    
    if ((self.type == HSAPIPreferencesItemModelTypeHSAPIRegionHost) && (other.type == HSAPIPreferencesItemModelTypeHSAPILocale)) {
        return compareNullableValues(self.hsAPIRegionHost, other.hsAPIRegionHost, @selector(isEqualToNumber:));
    } else if ((self.type == HSAPIPreferencesItemModelTypeHSAPILocale) && (other.type == HSAPIPreferencesItemModelTypeHSAPILocale)) {
        return compareNullableValues(self.hsAPILocale, other.hsAPILocale, @selector(isEqualToString:));
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.type;
}

- (NSString *)text {
    switch (self.type) {
        case HSAPIPreferencesItemModelTypeHSAPIRegionHost:
            return [LocalizableService localizableForHSAPIRegionHost:self.hsAPIRegionHost.unsignedIntegerValue];
        case HSAPIPreferencesItemModelTypeHSAPILocale:
            return [LocalizableService localizableForHSAPILocale:self.hsAPILocale];
        default:
            return nil;
    }
}

@end
