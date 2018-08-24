#import <UIKit/UIKit.h>

@class Post;

@interface PostListCell : UITableViewCell

- (void) configureForPost : (Post *) post;

@end
