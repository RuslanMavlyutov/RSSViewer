#import "RSSFeedModel.h"

@interface RSSFeedModel()

@property (strong, nonatomic) RSSParser *parser;
@property (strong, nonatomic) RSSLoader *loader;

@end

@implementation RSSFeedModel

- (id) initWithLoader:(RSSLoader *)loader parser:(RSSParser *)parser
{
    self.parser = parser;
    self.loader = loader;

    return self;
}

- (void) loadRSSWithUrl:(NSURL *)url completion:(ChannelBlock)completion
{
    [self.parser updateChannel];

    [self.loader loadChannelWithUrl:url competitionHandler: ^(NSData *data, NSError *error, NSString *warning) {
        NSLog(@"%@", error);
        if([warning isEqualToString:@""])
            [self.parser parserRss:data completion:^(Channel *channel, NSError *err, NSString *warning) {
                if(error)
                    NSLog(@"%@", error);
        }];
        completion(nil, error, warning);
    }];
}

@end
