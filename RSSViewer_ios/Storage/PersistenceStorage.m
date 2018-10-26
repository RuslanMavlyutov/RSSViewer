#import "AppDelegate.h"
#import "PersistenceStorage.h"
#import "Channel.h"
#import "Post.h"
#import "PersistentChannel.h"
#import "PersistentPost.h"
#import "PersistenceChannel+CoreDataClass.h"
#import "PersistencePost+CoreDataClass.h"
#import "ExtScope.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@implementation CoreDataPersistenceStorage {
    NSPersistentContainer *persistentContainer;
}

- (instancetype) init
{
    self = [super init];
    if (self != nil) {
        persistentContainer = [[NSPersistentContainer alloc] initWithName:@"RSSViewer"];
    }
    return self;
}

- (void) loadStorageWithCompletion : (void (^)(NSError *error)) completion
{
    [persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
}

- (void) saveChannel : (DomainChannel *) channel completion: (void (^)(NSError *error)) completion
{
    @weakify(self);
    [persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        @strongify(self);

        PersistenceChannel *persistenceChannel = [self fetchOrCreateChannelForURL: channel.urlChannel in:context];
        [ChannelMapper fillPersistenceChannel:persistenceChannel fromDomainChannel:channel];
        [self deleteAllPostsFromChannel:persistenceChannel in:context];
        [self mapPostsOfChannel:channel toPersistenceChannel:persistenceChannel using:context];

        NSError *error = nil;
        [context save:&error];
        if (error) {
            [self logError:error];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
}

- (PersistenceChannel *) fetchOrCreateChannelForURL : (NSURL *)url in: (NSManagedObjectContext *) ctx
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(PersistenceChannel.class)];
    request.predicate = [NSPredicate predicateWithFormat:@"urlChannel = %@", url.absoluteString];
    NSError *error = nil;
    NSArray<PersistenceChannel*> *matches = [ctx executeFetchRequest:request error:&error];
    if (error) {
        [self logError:error];
    }
    return matches.firstObject ?: [[PersistenceChannel alloc] initWithContext:ctx];
}

- (void) deleteAllPostsFromChannel : (PersistenceChannel *) channel
                                in : (NSManagedObjectContext *) ctx
{
    for (PersistencePost *post in channel.posts) {
        [ctx deleteObject:post];
    }
}

- (void) mapPostsOfChannel: (DomainChannel *)channel
      toPersistenceChannel:(PersistenceChannel *) persistenceChannel
                     using:(NSManagedObjectContext *)ctx
{
    for (int i = 0; i < [channel.posts count]; i++) {
        PersistencePost *persistencePost = [[PersistencePost alloc] initWithContext:ctx];
        [PostMapper fillPersistencePost:persistencePost fromDomainChannel: [channel.posts objectAtIndex:i]];
        [persistenceChannel addPostsObject:persistencePost];
    }
}

- (void) fetchAllChannels : (void (^)(NSArray<DomainChannel *> *, NSError*)) completion
{
    NSManagedObjectContext *context = persistentContainer.viewContext;
    [context performBlock:^{
        __block NSError *errorChannel = nil;
        __block NSArray *resultChannel;
        resultChannel = [context executeFetchRequest:[PersistenceChannel fetchRequest] error:&errorChannel];

        NSArray<PersistenceChannel *> *channels =  [[NSMutableArray alloc]initWithArray:resultChannel];
        NSMutableArray<DomainChannel *> *channelArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < channels.count; i++) {
            PersistentChannel *channel = [[PersistentChannel alloc] init];
            channel = (PersistentChannel*)[channel channelParser:[channels objectAtIndex:i]];
            [channelArray addObject:channel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([[NSArray alloc] initWithArray:channelArray], errorChannel);
        });
    }];
}

- (void) removeChannel : (DomainChannel *) channel completion: (void (^)(NSError *error)) completion
{
    @weakify(self);
    [persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        @strongify(self);

        PersistenceChannel *persistenceChannel = [self fetchOrCreateChannelForURL: channel.urlChannel in:context];
        [context deleteObject:persistenceChannel];

        NSError *error = nil;
        [context save:&error];
        if (error) {
            [self logError:error];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
}

- (void) logError : (NSError *) error
{
    NSLog(@"Error while fetching:\n%@",
          ([error localizedDescription] != nil) ?
          [error localizedDescription] : @"Unknown Error");
}

@end
