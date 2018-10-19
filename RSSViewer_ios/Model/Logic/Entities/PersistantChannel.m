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
    NSMutableArray<DomainPost *> *domainPosts = [[NSMutableArray alloc] init];
    for(RssPost *post in [rssChannel posts])
        [domainPosts addObject:(DomainPost *)post];
    channel.posts = [domainPosts copy];

    return channel;
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
