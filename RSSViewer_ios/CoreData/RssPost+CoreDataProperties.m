#import "RssPost+CoreDataProperties.h"

@implementation RssPost (CoreDataProperties)

+ (NSFetchRequest<RssPost *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RssPost"];
}

@dynamic descriptionPost;
@dynamic guid;
@dynamic link;
@dynamic pubDate;
@dynamic title;
@dynamic whichRssChannel;

@end
