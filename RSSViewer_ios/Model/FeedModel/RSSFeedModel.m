#import "RSSFeedModel.h"
#import "ExtScope.h"

@interface RSSFeedModel()

@property (strong, nonatomic) RSSParser *parser;
@property (strong, nonatomic) RSSLoader *loader;

@end

@implementation RSSFeedModel

-(instancetype) init
{
    self.loader = [[RSSLoader alloc] init];
    self.parser = [[RSSParser alloc] init];

    return self;
}

- (void) loadRSSWithUrl:(NSURL *)url completion:(ChannelBlock)completion
{
    @weakify(self);
    [self.loader loadChannelWithUrl:url competitionHandler: ^(NSData *data, NSError *error, NSString *warning) {
        @strongify(self);
        NSLog(@"%@", error);
        if([warning isEqualToString:@""]) {
            [self.parser parserRss: url : data completion:^(Channel *channel, NSError *err, NSString *warning) {
                if(err)
                    NSLog(@"%@", error);
                completion(channel, err, warning);
            }];
        }
        completion(nil, error, warning);
    }];
}

@end
