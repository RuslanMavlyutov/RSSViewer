#import "PersistantChannel.h"
#import "Post.h"

@implementation PersistantChannel

- (DomainChannel *) channelParser : (RssChannel *) rssChannel
{
    DomainChannel *channel = [[DomainChannel alloc] init];
    channel.title = [rssChannel title];
    channel.link = [rssChannel link];
    channel.description = [rssChannel descriptionChannel];
    channel.url = [rssChannel url];
    channel.urlChannel = [NSURL URLWithString:[rssChannel urlChannel]];
    channel.posts = [self sortedPosts:rssChannel];

    return channel;
}

- (NSArray *) sortedPosts : (RssChannel *) rssChannel
{
    NSMutableArray<DomainPost *> *domainPosts = [[NSMutableArray alloc] init];
    for(RssPost *post in [rssChannel posts])
        [domainPosts addObject:(DomainPost *)post];

    NSArray *sortedArray = [domainPosts sortedArrayUsingComparator:
                            ^NSComparisonResult(DomainPost *obj1, DomainPost *obj2) {
        NSDate *firstDate = (NSDate *)[(DomainPost *)obj1 pubDate];
        NSDate *secondDate = (NSDate *)[(DomainPost *)obj2 pubDate];
        return [firstDate compare:secondDate];
    }];

    return [[[sortedArray copy] reverseObjectEnumerator] allObjects];
}

@end


@implementation ChannelMapper

+ (void) fillPersistanceChannel : (RssChannel *) persistanceChannel
            fromDomainChannel: (DomainChannel *) domainChannel
{
    persistanceChannel.title = domainChannel.title;
    persistanceChannel.link = domainChannel.link;
    persistanceChannel.descriptionChannel = domainChannel.description;
    persistanceChannel.url = domainChannel.url;
    persistanceChannel.urlChannel = [domainChannel.urlChannel absoluteString];
}

@end
