#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Channel.h"

@class RSSFeedModel;
@class CoreDataPersistanceStorage;

@interface PostListViewController : UITableViewController

- (void) showChannel : (DomainChannel *) channel : (RSSFeedModel *) feedModel
          withStorage: (CoreDataPersistanceStorage *) strg;

@end
