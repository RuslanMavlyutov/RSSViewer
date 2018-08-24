#import <Foundation/Foundation.h>
#import "RSSLoader.h"
#import "RSSParser.h"

@interface RSSFeedModel : NSObject

- (instancetype) initWithLoader :(RSSLoader *)loader parser:(RSSParser *)parser;

-(void) loadRSSWithUrl: (NSURL *) url completion: (ChannelBlock) completion;

@end
