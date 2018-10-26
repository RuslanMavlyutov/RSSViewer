#import "Channel.h"
#import "PersistenceChannel+CoreDataClass.h"

@interface PersistentChannel : DomainChannel

- (DomainChannel *) channelParser : (PersistenceChannel *) PersistenceChannel;

@end

@interface ChannelMapper : NSObject

+ (void) fillPersistenceChannel : (PersistenceChannel *) persistenceChannel
               fromDomainChannel: (DomainChannel *) domainChannel;

@end
