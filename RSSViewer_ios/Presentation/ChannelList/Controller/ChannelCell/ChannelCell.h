#import <UIKit/UIKit.h>

@class Channel;

@interface ChannelCell : UITableViewCell

- (void) configureForChannel: (Channel *) channel;

@end
