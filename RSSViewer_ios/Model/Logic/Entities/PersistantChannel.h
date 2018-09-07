#import "Channel.h"
#import "RssChannel+CoreDataClass.h"

@interface PersistantChannel : Channel

- (Channel *) channelParser : (RssChannel *) rssChannel;

@end
