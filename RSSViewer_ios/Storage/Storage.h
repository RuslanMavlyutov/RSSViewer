#import <Foundation/Foundation.h>

@class Channel;

@interface Storage : NSObject

- (void) saveEtities : (Channel *) channel;
- (Channel *) loadChannel;

@end
