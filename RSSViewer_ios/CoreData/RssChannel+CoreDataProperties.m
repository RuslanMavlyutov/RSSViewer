#import "RssChannel+CoreDataProperties.h"

@implementation RssChannel (CoreDataProperties)

+ (NSFetchRequest<RssChannel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RssChannel"];
}

@dynamic descriptionChannel;
@dynamic link;
@dynamic title;
@dynamic url;
@dynamic urlChannel;
@dynamic posts;

@end
