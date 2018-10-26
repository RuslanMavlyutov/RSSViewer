#import "PersistencePost+CoreDataProperties.h"

@implementation PersistencePost (CoreDataProperties)

+ (NSFetchRequest<PersistencePost *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PersistencePost"];
}

@dynamic descriptionPost;
@dynamic guid;
@dynamic link;
@dynamic pubDate;
@dynamic title;
@dynamic channel;

@end
