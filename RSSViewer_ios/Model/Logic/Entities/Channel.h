#import <Foundation/Foundation.h>

@protocol Channel

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, retain) NSArray *posts;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURL *urlChannel;

@end

@interface DomainChannel : NSObject<Channel>

@end
