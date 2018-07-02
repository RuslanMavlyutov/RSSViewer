#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ParserController : UIViewController {
    NSMutableArray *titleArray;
    BOOL isRssChannelUpdate;
}

-(void) loadParser : (NSURL*) url;
-(id)initWithLink : (NSURL*) url;
@property (nonatomic, retain) NSMutableArray *feedPosts;
@property (nonatomic) BOOL isRssChannelUpdate;
@property (nonatomic, retain) NSMutableArray *titleArray;

@end
