#import <Foundation/Foundation.h>
#import "Channel.h"

typedef void(^ChannelBlock) (Channel *, NSError *, NSString *warning);

@interface RSSParser : NSObject

- (void) parserRss: (NSData *)rss completion: (ChannelBlock) completion;
- (void) updateChannel;

@property (nonatomic, retain) NSMutableArray *feedPosts;
@property (nonatomic, retain) NSMutableArray *titleArray;
@property (nonatomic) BOOL isRssChannelUpdate;

@end
