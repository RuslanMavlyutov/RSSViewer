#import "PersistantChannel.h"

@implementation PersistantChannel

- (Channel *) channelParser : (RssChannel *) rssChannel
{
    Channel *channel = [[Channel alloc] init];
    channel.title = [rssChannel title];
    channel.link = [rssChannel link];
    channel.description = [rssChannel descriptionChannel];
    channel.url = [NSURL URLWithString:[rssChannel url]];
    channel.urlChannel = [NSURL URLWithString:[rssChannel urlChannel]];

    return channel;
}

@end
