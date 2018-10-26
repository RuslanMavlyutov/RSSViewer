#import <Foundation/Foundation.h>

@class DomainChannel;

@protocol PersistenceStorage

- (void) saveChannel : (DomainChannel *) channel completion: (void (^)(NSError*)) completion;
- (void) fetchAllChannels : (void (^)(NSArray<DomainChannel *> *, NSError*)) completion;
- (void) loadStorageWithCompletion : (void (^)(NSError *error)) completion;
- (void) removeChannel : (DomainChannel *) channel completion: (void (^)(NSError *error)) completion;

@end

@interface CoreDataPersistenceStorage : NSObject<PersistenceStorage>

@end
