#import "ChannelMapper.h"
#import "Post.h"

@implementation ChannelMapper

- (DomainChannel *) channelParser : (PersistenceChannel *) persistenceChannel
{
    DomainChannel *channel = [[DomainChannel alloc] init];
    channel.title = [persistenceChannel title];
    channel.link = [persistenceChannel link];
    channel.description = [persistenceChannel descriptionChannel];
    channel.url = [persistenceChannel url];
    channel.urlChannel = [NSURL URLWithString:[persistenceChannel urlChannel]];
    channel.posts = [self sortedPosts:persistenceChannel];
    
    return channel;
}

- (NSArray *) sortedPosts : (PersistenceChannel *) persistenceChannel
{
    NSMutableArray<DomainPost *> *domainPosts = [[NSMutableArray alloc] init];
    for(PersistencePost *post in [persistenceChannel posts])
        [domainPosts addObject:(DomainPost *)post];
    
    NSArray *sortedArray = [domainPosts sortedArrayUsingComparator:
                            ^NSComparisonResult(DomainPost *obj1, DomainPost *obj2) {
                                NSDate *firstDate = (NSDate *)[(DomainPost *)obj1 pubDate];
                                NSDate *secondDate = (NSDate *)[(DomainPost *)obj2 pubDate];
                                return [firstDate compare:secondDate];
                            }];
    
    return [[[sortedArray copy] reverseObjectEnumerator] allObjects];
}

+ (void) fillPersistenceChannel : (PersistenceChannel *) persistenceChannel
            fromDomainChannel: (DomainChannel *) domainChannel
{
    persistenceChannel.title = domainChannel.title;
    persistenceChannel.link = domainChannel.link;
    persistenceChannel.descriptionChannel = domainChannel.description;
    persistenceChannel.url = domainChannel.url;
    persistenceChannel.urlChannel = [domainChannel.urlChannel absoluteString];
}

@end
