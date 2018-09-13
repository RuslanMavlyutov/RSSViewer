#import <Foundation/Foundation.h>

@class DomainChannel;

@protocol PersistanceStorage

- (void) saveChannel : (DomainChannel *) channel completion: (void (^)(NSError*, bool)) completion;
- (void) fetchAllChannels : (void (^)(NSArray<DomainChannel *> *, NSError*)) completion;

@end

@interface CoreDataPersistanceStorage : NSObject<PersistanceStorage>

@end