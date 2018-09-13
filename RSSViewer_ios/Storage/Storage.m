#import "AppDelegate.h"
#import "Storage.h"
#import "Channel.h"
#import "PersistantChannel.h"
#import "RssChannel+CoreDataClass.h"
#import "ExtScope.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@implementation Storage {
    NSMutableArray<RssChannel *> *channels;
    NSManagedObjectContext *context;
}

- (instancetype) init
{
    UIApplication *application = [UIApplication sharedApplication];
    context = ((AppDelegate*)[application delegate]).persistentContainer.viewContext;

    return self;
}

- (void) saveEtities : (Channel *) channel completion: (void (^)(NSError*, bool isUniqueLink)) completion
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)[application delegate]).persistentContainer;

    @weakify(self);
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        @strongify(self);
        RssChannel *rssChannel = [[RssChannel alloc] initWithEntity:[RssChannel entity] insertIntoManagedObjectContext:context];

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RssChannel"];
        request.predicate = [NSPredicate predicateWithFormat:@"urlChannel = %@", channel.urlChannel.absoluteString];

        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        bool isUniqueLink = false;

        if(!matches || error || [matches count] > 1) {
            if (error) {
                [self showError:error];
                return;
            }
        } else if ([matches count]) {
            NSLog(@"the same link");
        } else {
            rssChannel.title = channel.title;
            rssChannel.link = channel.link;
            rssChannel.descriptionChannel = channel.description;
            rssChannel.url = channel.url;
            rssChannel.urlChannel = [channel.urlChannel absoluteString];

            isUniqueLink = true;

            error = nil;
            [context save:&error];
            if (error) {
                [self showError:error];
                return;
            }
            [self->channels addObject:rssChannel];
        }
        completion(error, isUniqueLink);
    }];
}

- (NSArray<Channel *> *) loadChannel
{
    NSArray *result = [self fetchArrayInContext];

    channels =  [[NSMutableArray alloc]initWithArray:result];
    NSMutableArray<Channel *> *channelArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < channels.count; i++) {
        PersistantChannel *channel = [[PersistantChannel alloc] init];
        [channelArray addObject:[channel channelParser:[channels objectAtIndex:i]]];
    }

    return [[NSArray alloc] initWithArray:channelArray];
}

- (NSArray *)fetchArrayInContext
{
    __block NSArray *array;
    __block NSError *error = nil;
    [context performBlockAndWait:^{
        array = [self->context executeFetchRequest:[RssChannel fetchRequest] error:&error];
    }];

    if (error) {
        [self showError:error];
        return [NSArray array];
    }

    return array;
}

- (void) showError : (NSError *) error
{
    NSLog(@"Error while fetching:\n%@",
          ([error localizedDescription] != nil) ?
          [error localizedDescription] : @"Unknown Error");
}

@end
