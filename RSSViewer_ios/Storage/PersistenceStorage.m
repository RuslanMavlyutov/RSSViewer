#import "AppDelegate.h"
#import "PersistenceStorage.h"
#import "Channel.h"
#import "Post.h"
#import "ChannelMapper.h"
#import "PostMapper.h"
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

        PersistenceChannel *persistenceChannel = [self fetchChannelForURL: channel.urlChannel in:context] ?:
            [[PersistenceChannel alloc] initWithContext:context];
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

- (PersistenceChannel *) fetchChannelForURL : (NSURL *)url in: (NSManagedObjectContext *) ctx
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(PersistenceChannel.class)];
    request.predicate = [NSPredicate predicateWithFormat:@"urlChannel = %@", url.absoluteString];
    NSError *error = nil;
    NSArray<PersistenceChannel*> *matches = [ctx executeFetchRequest:request error:&error];
    if (error) {
        [self logError:error];
    }
    return matches.firstObject;
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
        NSError *error = nil;
        NSArray<PersistenceChannel *> *fetchedChannels = [context executeFetchRequest:[PersistenceChannel fetchRequest]
                                                                              error:&error];
        if(!fetchedChannels) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        NSArray<PersistenceChannel *> *channels =  [[NSMutableArray alloc]initWithArray:fetchedChannels];
        NSMutableArray<DomainChannel *> *channelArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < channels.count; i++) {
            ChannelMapper *channel = [[ChannelMapper alloc] init];
            channel = (ChannelMapper *)[channel channelParser:[channels objectAtIndex:i]];
            [channelArray addObject:channel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([channelArray copy], error);
        });
    }];
}

- (void) removeChannel : (DomainChannel *) channel completion: (void (^)(NSError *error)) completion
{
    @weakify(self);
    [persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        @strongify(self);

        PersistenceChannel *persistenceChannel = [self fetchChannelForURL: channel.urlChannel in:context];
        NSError *error = nil;
        if(persistenceChannel) {
            [context deleteObject:persistenceChannel];
            [context save:&error];
            if (error) {
                [self logError:error];
            }
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
