#import "ChannelCell.h"

@implementation ChannelCell

@synthesize titleChannel, subtitleChannel, imageChannel;

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageChannel.frame = CGRectMake(0, 0, 60, 60);
}

@end
