#import <Foundation/Foundation.h>

@interface Post : NSObject {
    NSString *title;
    NSString *description;
    NSDate *pubDate;
    NSString *guid;
}

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSDate *pubDate;
@property (copy, nonatomic) NSString *guid;

@end
