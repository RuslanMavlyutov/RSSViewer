#import <UIKit/UIKit.h>

@interface RssUrlParser : NSObject

- (NSString *) checkUrlWithString : (NSString *) urlStr error: (NSError**) error;

@end
