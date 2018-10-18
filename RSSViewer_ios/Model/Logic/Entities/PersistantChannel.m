#import "PersistantChannel.h"

@implementation PersistantChannel

- (DomainChannel *) channelParser : (RssChannel *) rssChannel
{
    DomainChannel *channel = [[DomainChannel alloc] init];
    channel.title = [rssChannel title];
    channel.link = [rssChannel link];
    channel.description = [rssChannel descriptionChannel];
    channel.url = [rssChannel url];
    channel.urlChannel = [NSURL URLWithString:[rssChannel urlChannel]];
    NSMutableArray<DomainPost *> *domainPosts = [[NSMutableArray alloc] init];
    for(RssPost *post in [rssChannel posts])
        [domainPosts addObject:(DomainPost *)post];
    channel.posts = [domainPosts copy];

    return channel;
}

@end
