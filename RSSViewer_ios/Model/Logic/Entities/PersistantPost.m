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
            fromDomainChannel: (DomainPost *) post
{
    persistancePost.title = [post title];
    persistancePost.descriptionPost = [post description];
    persistancePost.pubDate = [post pubDate];
    persistancePost.guid = [post guid];
    persistancePost.link = [post link];
}

@end
