#import <Foundation/Foundation.h>
#import "Channel.h"

typedef void(^ChannelBlock) (Channel *, NSError *, NSString *warning);

@interface RSSParser : NSObject

- (void) parserRss: (NSURL *) url : (NSData *)rss completion: (ChannelBlock) completion;

@end