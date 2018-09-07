#import "AppDelegate.h"
#import "Storage.h"
#import "Channel.h"
#import "PersistantChannel.h"
#import "RssChannel+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@implementation Storage {
    NSMutableArray<RssChannel *> *channels;
}

- (void) saveEtities : (Channel *) channel
{
    UIApplication *application = [UIApplication sharedApplication];
    NSManagedObjectContext *context = ((AppDelegate*)[application delegate]).persistentContainer.viewContext;

    RssChannel *rssChannel = [[RssChannel alloc] initWithEntity:[RssChannel entity] insertIntoManagedObjectContext:context];
    [rssChannel setValue:channel.title forKey:@"title"];
    [rssChannel setValue:channel.link forKey:@"link"];
    [rssChannel setValue:channel.description forKey:@"descriptionChannel"];
    [rssChannel setValue:channel.url forKey:@"url"];
    [rssChannel setValue:channel.urlChannel.absoluteString forKey:@"urlChannel"];

    [context save:nil];
    [channels addObject:rssChannel];
}

- (NSArray<Channel *> *) loadChannel
{
    UIApplication *application = [UIApplication sharedApplication];
    NSManagedObjectContext *context = ((AppDelegate*)[application delegate]).persistentContainer.viewContext;

    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:[RssChannel fetchRequest] error:&error];

    channels =  [[NSMutableArray alloc]initWithArray:result];
    NSMutableArray<Channel *> *channelArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < channels.count; i++) {
        PersistantChannel *channel = [[PersistantChannel alloc] init];
        [channelArray addObject:[channel channelParser:[channels objectAtIndex:i]]];
    }

    return [[NSArray alloc] initWithArray:channelArray];
}

- (NSArray *)fetchArrayInContext:(NSManagedObjectContext *)context
{
    NSPredicate *pred = nil;
    __block NSArray *array;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RSSChannel"];
    [request setPredicate:pred];

    __block NSError *error   = nil;
    [context performBlockAndWait:^{
        array = [context executeFetchRequest:request error:&error];
    }];

    if (error) {
        NSLog(@"Error while fetching:\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
        return [NSArray array];
    }

    return array;
}

@end
