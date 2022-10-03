#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDiffableDataSourceSnapshot (Sort)
- (void)sortItemsWithSectionIdentifiers:(NSArray *)sectionIdentifiers usingComparator:(NSComparator NS_NOESCAPE)cmptr;
- (void)sortSectionsUsingComparator:(NSComparator NS_NOESCAPE)cmptr;
@end

NS_ASSUME_NONNULL_END
