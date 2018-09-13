#import <Foundation/Foundation.h>

@class DomainChannel;

typedef void(^ChannelBlock) (DomainChannel *, NSError *, NSString *warning);

@interface RSSParser : NSObject

- (void) parserRss: (NSURL *) url : (NSData *)rss completion: (ChannelBlock) completion;

@end
