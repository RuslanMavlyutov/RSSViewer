#import "AppDelegate.h"
#import "PersistanceStorage.h"
#import "Channel.h"
#import "PersistantChannel.h"
#import "RssChannel+CoreDataClass.h"
#import "ExtScope.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@implementation CoreDataPersistanceStorage {
    NSMutableArray<RssChannel *> *channels;
    NSManagedObjectContext *context;
}

- (instancetype) init
{
    UIApplication *application = [UIApplication sharedApplication];
    context = ((AppDelegate*)[application delegate]).persistentContainer.viewContext;

    return self;
}

- (void) saveChannel : (DomainChannel *) channel completion: (void (^)(NSError *error, bool isUniqueLink)) completion
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

- (NSArray<DomainChannel *> *) fetchAllChannels : (void (^)(NSError*)) completion
{
    __block NSError *error = nil;
    __block NSArray *result;
    [context performBlockAndWait:^{
        result = [self->context executeFetchRequest:[RssChannel fetchRequest] error:&error];
    }];

    channels =  [[NSMutableArray alloc]initWithArray:result];
    NSMutableArray<DomainChannel *> *channelArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < channels.count; i++) {
        PersistantChannel *channel = [[PersistantChannel alloc] init];
        [channelArray addObject:[channel channelParser:[channels objectAtIndex:i]]];
    }
    completion(error);
    return [[NSArray alloc] initWithArray:channelArray];
}

- (void) showError : (NSError *) error
{
    NSLog(@"Error while fetching:\n%@",
          ([error localizedDescription] != nil) ?
          [error localizedDescription] : @"Unknown Error");
}

@end
