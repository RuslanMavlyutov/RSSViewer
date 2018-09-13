#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Channel.h"
#import "RSSFeedModel.h"

@interface PostListViewController : UITableViewController

- (void) showChannel : (DomainChannel *) channel : (RSSFeedModel *) feedModel;

@end
