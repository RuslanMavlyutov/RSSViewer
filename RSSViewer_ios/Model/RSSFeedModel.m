#import "RSSFeedModel.h"

@interface RSSFeedModel()

@property (strong, nonatomic) RSSParser *parser;
@property (strong, nonatomic) RSSLoader *loader;

@end

@implementation RSSFeedModel

-(id) init
{
    _loader = [[RSSLoader alloc] init];
    _parser = [[RSSParser alloc] init];

    return self;
}

- (void) loadRSSWithUrl:(NSURL *)url completion:(ChannelBlock)completion
{
    [self.loader loadChannelWithUrl:url competitionHandler: ^(NSData *data, NSError *error, NSString *warning) {
        NSLog(@"%@", error);
        if([warning isEqualToString:@""]) {
            [self.parser parserRss:data completion:^(Channel *channel, NSError *err, NSString *warning) {
                if(err)
                    NSLog(@"%@", error);
                completion(channel, err, warning);
            }];
        }
        completion(nil, error, warning);
    }];
}

@end
