#import "PostMapper.h"
#import "Channel.h"

@implementation PostMapper

- (DomainPost *) postParser : (PersistencePost *) persistencePost
{
    DomainPost *post = [[DomainPost alloc] init];
    post.title = [persistencePost title];
    post.description = [persistencePost descriptionPost];
    post.pubDate = [persistencePost pubDate];
    post.guid = [persistencePost guid];
    post.link = [persistencePost link];

    return post;
}

+ (void) fillPersistencePost : (PersistencePost *) persistencePost
            fromDomainChannel: (DomainPost *) post
{
    persistencePost.title = [post title];
    persistencePost.descriptionPost = [post description];
    persistencePost.pubDate = [post pubDate];
    persistencePost.guid = [post guid];
    persistencePost.link = [post link];
}

@end
