#import "PersistantChannel.h"

@implementation PersistantChannel

- (DomainChannel *) channelParser : (RssChannel *) rssChannel
{
    DomainChannel *channel = [[DomainChannel alloc] init];
    channel.title = [rssChannel title];
    channel.link = [rssChannel link];
    channel.description = [rssChannel descriptionChannel];
    channel.url = [NSURL URLWithString:[rssChannel url]];
    channel.urlChannel = [NSURL URLWithString:[rssChannel urlChannel]];

    return channel;
}

@end
