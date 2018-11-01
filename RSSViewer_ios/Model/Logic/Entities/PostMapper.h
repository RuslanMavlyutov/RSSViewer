#import "Post.h"
#import "PersistencePost+CoreDataClass.h"
@class DomainChannel;

@interface PostMapper : DomainPost

- (DomainPost *) postParser : (PersistencePost *) persistencePost;

+ (void) fillPersistencePost : (PersistencePost *) persistencePost
            fromDomainChannel: (DomainPost *) post;

@end
