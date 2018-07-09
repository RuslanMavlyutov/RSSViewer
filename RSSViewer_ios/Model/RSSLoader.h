#import <Foundation/Foundation.h>

@interface RSSLoader : NSObject

- (void) loadChannelWithUrl: (NSURL *)url competitionHandler: (void (^)(NSData*, NSError*, NSString*))competitionHandler;

@end
