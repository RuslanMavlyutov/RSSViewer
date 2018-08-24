#import "ChannelCell.h"
#import "Channel.h"

@interface ChannelCell ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end

@implementation ChannelCell

@synthesize titleLabel, subtitleLabel, imageView;

- (void) configureForChannel: (Channel *) channel
{
    titleLabel.text = [channel title];
    subtitleLabel.text = [channel description];
    NSURL *urlImage = [NSURL URLWithString:[channel url]];
    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlImage]];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 60, 60);
}

@end
