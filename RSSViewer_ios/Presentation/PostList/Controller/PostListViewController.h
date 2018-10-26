#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Channel.h"

@class RSSFeedModel;
@class CoreDataPersistenceStorage;

@interface PostListViewController : UITableViewController

- (void) showChannel : (DomainChannel *) channel : (RSSFeedModel *) feedModel
          withStorage: (CoreDataPersistenceStorage *) strg;

@end
