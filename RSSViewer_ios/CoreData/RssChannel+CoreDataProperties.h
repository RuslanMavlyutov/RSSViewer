#import "RssChannel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RssChannel (CoreDataProperties)

+ (NSFetchRequest<RssChannel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *descriptionChannel;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *urlChannel;
@property (nullable, nonatomic, retain) NSSet<RssPost *> *posts;

@end

@interface RssChannel (CoreDataGeneratedAccessors)

- (void)addPostsObject:(RssPost *)value;
- (void)removePostsObject:(RssPost *)value;
- (void)addPosts:(NSSet<RssPost *> *)values;
- (void)removePosts:(NSSet<RssPost *> *)values;

@end

NS_ASSUME_NONNULL_END
