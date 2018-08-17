#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *pubDate;
@property (copy, nonatomic) NSString *guid;
@property (copy, nonatomic) NSString *link;

@end
