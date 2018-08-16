#import <Foundation/Foundation.h>
#import "RSSLoader.h"
#import "RSSParser.h"

@interface RSSFeedModel : NSObject

-(void) loadRSSWithUrl: (NSURL *) url completion: (ChannelBlock) completion;

@end
