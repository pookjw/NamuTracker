#import "TrackingRootViewController.h"
#import "PassthroughView.h"

@interface TrackingRootViewController ()
@end

@implementation TrackingRootViewController

- (void)loadView {
    self.view = [PassthroughView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5f];
}

@end
