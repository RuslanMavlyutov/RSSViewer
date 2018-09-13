#import "ChannelCell.h"
#import "Channel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ChannelCell ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end

@implementation ChannelCell

@synthesize titleLabel, subtitleLabel, imageView;

- (void) configureForChannel: (DomainChannel *) channel
{
    titleLabel.text = [channel title];
    subtitleLabel.text = [channel description];
    [imageView sd_setImageWithURL:[channel url]];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 60, 60);
}

@end
