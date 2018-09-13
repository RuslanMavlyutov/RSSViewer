#import <UIKit/UIKit.h>

@class DomainPost;

@interface PostListCell : UITableViewCell

- (void) configureForPost : (DomainPost *) post;

@end
