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
        RssChannel *rssChannel = [[RssChannel alloc] initWithContext:context];

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(RssChannel.class)];
        request.predicate = [NSPredicate predicateWithFormat:@"urlChannel = %@", channel.urlChannel.absoluteString];

        NSError *error = nil;
        RssChannel *persistanceChannel = nil;
        NSArray<RssChannel*> *matches = [context executeFetchRequest:request error:&error];
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

            RssPost *rssPost;
            NSFetchRequest *requestPost;
            NSError *err = nil;
            NSArray<RssPost*> *matchesPost;
            for (int i = 0; i < [channel.posts count]; i++) {
                rssPost = [[RssPost alloc] initWithContext:context];
                requestPost = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(RssPost.class)];
                matchesPost = [context executeFetchRequest:requestPost error:&err];

                if(!matchesPost || err || [matches count] > 1) {
                    if (error) {
                        [self showError:error];
                        return;
                    }
                } else if ([matches count]) {
                    NSLog(@"the same link");
                } else {
                    rssPost.title = [channel.posts[i] title];
                    rssPost.descriptionPost = [channel.posts[i] description];
                    rssPost.pubDate = [channel.posts[i] pubDate];
                    rssPost.guid = [channel.posts[i] guid];
                    rssPost.link = [channel.posts[i] link];
                }
                error = nil;
                [context save:&error];
                if (error) {
                    [self showError:error];
                    return;
                }
                [self->posts addObject:rssPost];
            }
        }
        completion(error, isUniqueLink);
    }];
}

- (void) fetchAllChannels : (void (^)(NSArray<DomainChannel *> *, NSError*)) completion
{
    __block NSError *errorChannel = nil;
    __block NSError *errorPost = nil;
    __block NSArray *resultChannel;
    __block NSArray *resultPosts;
    [context performBlockAndWait:^{
        resultChannel = [self->context executeFetchRequest:[RssChannel fetchRequest] error:&errorChannel];
        resultPosts = [self->context executeFetchRequest:[RssPost fetchRequest] error:&errorPost];
    }];

    posts = [[NSMutableArray alloc] initWithArray:resultPosts];
    NSMutableArray<DomainPost *> *postArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < posts.count; i++) {
        PersistantPost *post = [[PersistantPost alloc] init];
        [postArray addObject:[post postParser:[posts objectAtIndex:i]]];
    }

    channels =  [[NSMutableArray alloc]initWithArray:resultChannel];
    NSMutableArray<DomainChannel *> *channelArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < channels.count; i++) {
        PersistantChannel *channel = [[PersistantChannel alloc] init];
        channel = (PersistantChannel*)[channel channelParser:[channels objectAtIndex:i]];
        channel.posts = posts;
        [channelArray addObject:channel];
    }

    completion([[NSArray alloc] initWithArray:channelArray], errorChannel);
}

- (void) showError : (NSError *) error
{
    NSLog(@"Error while fetching:\n%@",
          ([error localizedDescription] != nil) ?
          [error localizedDescription] : @"Unknown Error");
}

@end
