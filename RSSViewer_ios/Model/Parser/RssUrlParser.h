#import <UIKit/UIKit.h>

@interface RssUrlParser : UITableViewCell

- (NSString *) checkUrlWithString : (NSString *) urlStr error: (NSError**) error;

@end
