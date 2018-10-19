#import "Channel.h"
#import "RssChannel+CoreDataClass.h"

@interface PersistantChannel : DomainChannel

- (DomainChannel *) channelParser : (RssChannel *) rssChannel;

@end

@interface ChannelMapper : NSObject

+ (void) fillPersistanceChannel : (RssChannel *) persistanceChannel
               fromDomainChannel: (DomainChannel *) domainChannel;

@end
