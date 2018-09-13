#import "Channel.h"
#import "RssChannel+CoreDataClass.h"

@interface PersistantChannel : DomainChannel

- (DomainChannel *) channelParser : (RssChannel *) rssChannel;

@end
