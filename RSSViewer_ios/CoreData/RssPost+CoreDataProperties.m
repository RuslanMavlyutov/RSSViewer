//
//  RssPost+CoreDataProperties.m
//  
//
//  Created by Ruslan Mavlyutov on 13/09/2018.
//
//

#import "RssPost+CoreDataProperties.h"

@implementation RssPost (CoreDataProperties)

+ (NSFetchRequest<RssPost *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RssPost"];
}

@dynamic title;
@dynamic descriptionPost;
@dynamic pubDate;
@dynamic guid;
@dynamic link;
@dynamic whichRssChannel;

@end
