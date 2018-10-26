#import "PersistenceChannel+CoreDataProperties.h"

@implementation PersistenceChannel (CoreDataProperties)

+ (NSFetchRequest<PersistenceChannel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PersistenceChannel"];
}

@dynamic descriptionChannel;
@dynamic link;
@dynamic title;
@dynamic url;
@dynamic urlChannel;
@dynamic posts;

@end
