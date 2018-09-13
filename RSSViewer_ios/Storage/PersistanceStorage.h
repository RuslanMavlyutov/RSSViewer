#import <Foundation/Foundation.h>

@class DomainChannel;

@protocol PersistanceStorage

- (void) saveChannel : (DomainChannel *) channel completion: (void (^)(NSError*, bool)) completion;
- (NSArray<DomainChannel *> *) fetchAllChannels : (void (^)(NSError*)) completion;

@end

@interface CoreDataPersistanceStorage : NSObject<PersistanceStorage>

@end
