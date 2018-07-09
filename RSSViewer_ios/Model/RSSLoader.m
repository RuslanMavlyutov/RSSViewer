#import "RSSLoader.h"

@implementation RSSLoader

- (void) loadChannelWithUrl: (NSURL *)url competitionHandler: (void (^)(NSData*, NSError*, NSString*))competitionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        NSString *warning;
        if(error) {
            warning = @"Page can't be found";
        } else {
            NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
            if(statusCode != 404) {
                warning = @"";
            } else {
                warning = [NSString stringWithFormat:@"The url is invalid! - %ld", (long)statusCode];
            }
        }
        if(competitionHandler) {
            if(error) {
                competitionHandler(data, error, warning);
            } else {
                competitionHandler(data, error, warning);
            }
        }
    }];

    [dataTask resume];
}

@end
