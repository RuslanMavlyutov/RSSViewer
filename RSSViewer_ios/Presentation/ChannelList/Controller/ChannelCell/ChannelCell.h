#import <UIKit/UIKit.h>

@class DomainChannel;

@interface ChannelCell : UITableViewCell

- (void) configureForChannel: (DomainChannel *) channel;

@end
