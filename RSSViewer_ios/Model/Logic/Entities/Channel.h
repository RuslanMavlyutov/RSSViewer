#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSArray *posts;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURL *urlChannel;

@end
