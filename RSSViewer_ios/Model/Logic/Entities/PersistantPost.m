#import "PersistantPost.h"

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
