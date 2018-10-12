#import "Post.h"
#import "RssPost+CoreDataClass.h"

@interface PersistantPost : DomainPost

- (DomainPost *) postParser : (RssPost *) rssPost;

@end
