#import "AppDelegate.h"
#import "PersistanceStorage.h"
#import "Channel.h"
#import "Post.h"
#import "PersistantChannel.h"
#import "PersistantPost.h"
#import "RssChannel+CoreDataClass.h"
#import "RssPost+CoreDataClass.h"
#import "ExtScope.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@implementation CoreDataPersistanceStorage {
    NSMutableArray<RssChannel *> *channels;
    NSMutableArray<RssPost *> *posts;
    NSManagedObjectContext *context;
}

- (instancetype) init
{
    UIApplication *application = [UIApplication sharedApplication];
    context = ((AppDelegate*)[application delegate]).persistentContainer.viewContext;

    return self;
}

- (void) saveChannel : (DomainChannel *) channel completion: (void (^)(NSError *error)) completion
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)[application delegate]).persistentContainer;

    @weakify(self);
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        @strongify(self);

        RssChannel *persistanceChannel = nil;
        persistanceChannel = [self fetchOrCreateInContext:context : channel];

        NSError *error = nil;
        [context save:&error];
        if (error) {
            [self logError:error];
            return;
        }
        completion(error);
    }];
}

- (RssChannel *) fetchOrCreateInContext : (NSManagedObjectContext *) ctx : (DomainChannel *) channel
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(RssChannel.class)];
    request.predicate = [NSPredicate predicateWithFormat:@"urlChannel = %@", channel.urlChannel.absoluteString];
    NSError *error = nil;
    NSArray<RssChannel*> *matches = [ctx executeFetchRequest:request error:&error];
    if (error) {
        [self logError:error];
    }

    RssChannel *persistanceChannel = nil;
    if ([matches count] ==  1) {
        persistanceChannel = matches[0];
        for (RssPost *post in persistanceChannel.posts) {
            [ctx deleteObject:post];
        }
    } else {
        persistanceChannel = [[RssChannel alloc] initWithContext:ctx];
        [ChannelMapper fillPersistanceChannel:persistanceChannel fromDomainChannel:channel];
    }

    for (int i = 0; i < [channel.posts count]; i++) {
        RssPost *persistancePost = [[RssPost alloc] initWithContext:ctx];
        [PostMapper fillPersistancePost:persistancePost fromDomainChannel: [channel.posts objectAtIndex:i]];
        [persistanceChannel addPostsObject:persistancePost];
    }
    return persistanceChannel;
}

- (void) fetchAllChannels : (void (^)(NSArray<DomainChannel *> *, NSError*)) completion
{
    __block NSError *errorChannel = nil;
    __block NSArray *resultChannel;
    [context performBlockAndWait:^{
        resultChannel = [self->context executeFetchRequest:[RssChannel fetchRequest] error:&errorChannel];
    }];

    channels =  [[NSMutableArray alloc]initWithArray:resultChannel];
    NSMutableArray<DomainChannel *> *channelArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < channels.count; i++) {
        PersistantChannel *channel = [[PersistantChannel alloc] init];
        channel = (PersistantChannel*)[channel channelParser:[channels objectAtIndex:i]];
        [channelArray addObject:channel];
    }

    completion([[NSArray alloc] initWithArray:channelArray], errorChannel);
}

- (void) logError : (NSError *) error
{
    NSLog(@"Error while fetching:\n%@",
          ([error localizedDescription] != nil) ?
          [error localizedDescription] : @"Unknown Error");
}

@end
