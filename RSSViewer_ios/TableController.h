#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TableController : UITableViewController {
    NSMutableArray *feed;
    NSArray *array;
}

@property (nonatomic, retain) NSMutableArray *posts;

- (void) loadNews : (NSArray *) array;

@end
