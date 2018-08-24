#import "PostListCell.h"
#import "Post.h"

@interface PostListCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation PostListCell

@synthesize titleLabel, subtitleLabel;

- (void) configureForPost : (Post *) post
{
    titleLabel.text = [post title];
    subtitleLabel.text = [post pubDate];
}

@end
