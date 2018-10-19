#import "Post.h"
#import "RssPost+CoreDataClass.h"
@class DomainChannel;

@interface PersistantPost : DomainPost

- (DomainPost *) postParser : (RssPost *) rssPost;

@end

@interface PostMapper : NSObject

+ (void) fillPersistancePost : (RssPost *) persistancePost
            fromDomainChannel: (DomainChannel *) domainChannel;

@end
