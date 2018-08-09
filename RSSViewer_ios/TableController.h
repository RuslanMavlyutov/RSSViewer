#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Channel.h"
#import "RSSFeedModel.h"

@interface TableController : UITableViewController

- (void) showChannel : (Channel *) channel : (RSSFeedModel *) feedModel;

@end
