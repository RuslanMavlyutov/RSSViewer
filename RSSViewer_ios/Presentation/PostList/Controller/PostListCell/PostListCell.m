#import "PostListCell.h"
#import "Post.h"

@interface PostListCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation PostListCell

@synthesize titleLabel, subtitleLabel;

- (void) configureForPost : (DomainPost *) post
{
    titleLabel.text = [post title];
    subtitleLabel.text = [post pubDate];
}

@end
