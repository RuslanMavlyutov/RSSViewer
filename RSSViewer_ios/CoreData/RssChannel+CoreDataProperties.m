//
//  RssChannel+CoreDataProperties.m
//
//
//  Created by Ruslan Mavlyutov on 07/09/2018.
//
//

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

@end
