#import "Post.h"
#import "PersistencePost+CoreDataClass.h"
@class DomainChannel;

@interface PersistentPost : DomainPost

- (DomainPost *) postParser : (PersistencePost *) persistencePost;

@end

@interface PostMapper : NSObject

+ (void) fillPersistencePost : (PersistencePost *) persistencePost
            fromDomainChannel: (DomainPost *) post;

@end
