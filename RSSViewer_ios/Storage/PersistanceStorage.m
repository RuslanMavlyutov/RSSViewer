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

- (void) saveChannel : (DomainChannel *) channel completion: (void (^)(NSError *error, bool isUniqueLink)) completion
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)[application delegate]).persistentContainer;

    @weakify(self);
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        @strongify(self);

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(RssChannel.class)];
        request.predicate = [NSPredicate predicateWithFormat:@"urlChannel = %@", channel.urlChannel.absoluteString];

        NSError *error = nil;
        RssChannel *persistanceChannel = nil;
        NSArray<RssChannel*> *matches = [context executeFetchRequest:request error:&error];
        bool isUniqueLink = false;

        if ([matches count] ==  1) {
            persistanceChannel = matches[0];
        } else {
            persistanceChannel = [[RssChannel alloc] initWithContext:context];

            persistanceChannel.title = channel.title;
            persistanceChannel.link = channel.link;
            persistanceChannel.descriptionChannel = channel.description;
            persistanceChannel.url = channel.url;
            persistanceChannel.urlChannel = [channel.urlChannel absoluteString];

            RssPost *persistancePost = nil;
            for (int i = 0; i < [channel.posts count]; i++) {
                persistancePost = [[RssPost alloc] initWithContext:context];
                persistancePost.title = [channel.posts[i] title];
                persistancePost.descriptionPost = [channel.posts[i] description];
                persistancePost.pubDate = [channel.posts[i] pubDate];
                persistancePost.guid = [channel.posts[i] guid];
                persistancePost.link = [channel.posts[i] link];
                [persistanceChannel addPostsObject:persistancePost];
            }

            isUniqueLink = true;

            error = nil;
            [context save:&error];
            if (error) {
                [self logError:error];
                return;
            }
            [self->channels addObject:persistanceChannel];
        }
        completion(error, isUniqueLink);
    }];
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
