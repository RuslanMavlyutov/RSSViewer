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

        RssChannel *persistanceChannel = [self fetchOrCreateChannelForURL: channel.urlChannel in:context];
        [ChannelMapper fillPersistanceChannel:persistanceChannel fromDomainChannel:channel];
        [self deleteAllPostsFromChannel:persistanceChannel in:context];
        [self mapPostsOfChannel:channel toPersistenceChannel:persistanceChannel using:context];

        NSError *error = nil;
        [context save:&error];
        if (error) {
            [self logError:error];
        }
        completion(error);
    }];
}

- (RssChannel *) fetchOrCreateChannelForURL : (NSURL *)url in: (NSManagedObjectContext *) ctx
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(RssChannel.class)];
    request.predicate = [NSPredicate predicateWithFormat:@"urlChannel = %@", url.absoluteString];
    NSError *error = nil;
    NSArray<RssChannel*> *matches = [ctx executeFetchRequest:request error:&error];
    if (error) {
        [self logError:error];
    }
    return matches.firstObject ?: [[RssChannel alloc] initWithContext:ctx];
}

- (void) deleteAllPostsFromChannel : (RssChannel *) channel
                                in : (NSManagedObjectContext *) ctx
{
    for (RssPost *post in channel.posts) {
        [ctx deleteObject:post];
    }
}

- (void) mapPostsOfChannel: (DomainChannel *)channel
      toPersistenceChannel:(RssChannel *) persistanceChannel
                     using:(NSManagedObjectContext *)ctx
{
    for (int i = 0; i < [channel.posts count]; i++) {
        RssPost *persistancePost = [[RssPost alloc] initWithContext:ctx];
        [PostMapper fillPersistancePost:persistancePost fromDomainChannel: [channel.posts objectAtIndex:i]];
        [persistanceChannel addPostsObject:persistancePost];
    }
}

- (void) fetchAllChannels : (void (^)(NSArray<DomainChannel *> *, NSError*)) completion
{
    NSManagedObjectContext *context = persistentContainer.viewContext;
    [context performBlock:^{
        __block NSError *errorChannel = nil;
        __block NSArray *resultChannel;
        resultChannel = [context executeFetchRequest:[RssChannel fetchRequest] error:&errorChannel];

        NSArray<RssChannel *> *channels =  [[NSMutableArray alloc]initWithArray:resultChannel];
        NSMutableArray<DomainChannel *> *channelArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < channels.count; i++) {
            PersistantChannel *channel = [[PersistantChannel alloc] init];
            channel = (PersistantChannel*)[channel channelParser:[channels objectAtIndex:i]];
            [channelArray addObject:channel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([[NSArray alloc] initWithArray:channelArray], errorChannel);
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
