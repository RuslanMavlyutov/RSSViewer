#import "Channel.h"
#import "PersistenceChannel+CoreDataClass.h"

@interface ChannelMapper : DomainChannel

- (DomainChannel *) channelParser : (PersistenceChannel *) PersistenceChannel;

+ (void) fillPersistenceChannel : (PersistenceChannel *) persistenceChannel
               fromDomainChannel: (DomainChannel *) domainChannel;

@end
