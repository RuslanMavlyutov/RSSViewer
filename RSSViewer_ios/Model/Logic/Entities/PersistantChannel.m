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
    channel.posts = [[rssChannel posts] allObjects];

    return channel;
}

@end
