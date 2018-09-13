#import <Foundation/Foundation.h>

@class Channel;

@interface Storage : NSObject

- (void) saveEtities : (Channel *) channel completion: (void (^)(NSError*, bool)) completion;
- (NSArray<Channel *> *) loadChannel;

@end
