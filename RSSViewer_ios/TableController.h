#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ParserController.h"

@interface TableController : UIViewController {
    NSMutableArray *feed;
    NSArray *array;
}

@property (nonatomic, retain) ParserController *parserFeed;
@property (nonatomic, retain) NSMutableArray *posts;

@end
