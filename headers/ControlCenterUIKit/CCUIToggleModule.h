#import <UIKit/UIKit.h>
#import <ControlCenterUIKit/CCUIContentModuleContentViewController.h>

@interface CCUIToggleModule : NSObject
@property (nonatomic, getter=isSelected) BOOL selected;
@property (readonly, copy, nonatomic) UIImage* iconGlyph;
@property (readonly, copy, nonatomic) UIImage* selectedIconGlyph;
@property (readonly, copy, nonatomic) UIColor* selectedColor;
@property (readonly, nonatomic) double glyphScale;
@property (readonly, nonatomic) UIViewController<CCUIContentModuleContentViewController>* contentViewController;

@end
