#import <Foundation/Foundation.h>

@class DomainPost;

@protocol Channel

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, retain) NSArray<DomainPost *> *posts;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSURL *urlChannel;

@end

@interface DomainChannel : NSObject<Channel>

@end
