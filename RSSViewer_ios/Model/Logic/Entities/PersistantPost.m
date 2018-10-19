#import "PersistantPost.h"
#import "Channel.h"

@implementation PersistantPost

- (DomainPost *) postParser : (RssPost *) rssPost
{
    DomainPost *post = [[DomainPost alloc] init];
    post.title = [rssPost title];
    post.description = [rssPost descriptionPost];
    post.pubDate = [rssPost pubDate];
    post.guid = [rssPost guid];
    post.link = [rssPost link];

    return post;
}

@end

@implementation PostMapper

+ (void) fillPersistancePost : (RssPost *) persistancePost
            fromDomainChannel: (DomainChannel *) domainChannel
{
    for (int i = 0; i < [domainChannel.posts count]; i++) {
        persistancePost.title = [domainChannel.posts[i] title];
        persistancePost.descriptionPost = [domainChannel.posts[i] description];
        persistancePost.pubDate = [domainChannel.posts[i] pubDate];
        persistancePost.guid = [domainChannel.posts[i] guid];
        persistancePost.link = [domainChannel.posts[i] link];
    }
}

@end
