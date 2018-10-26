#import "PersistenceChannel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PersistenceChannel (CoreDataProperties)

+ (NSFetchRequest<PersistenceChannel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *descriptionChannel;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *urlChannel;
@property (nullable, nonatomic, retain) NSSet<PersistencePost *> *posts;

@end

@interface PersistenceChannel (CoreDataGeneratedAccessors)

- (void)addPostsObject:(PersistencePost *)value;
- (void)removePostsObject:(PersistencePost *)value;
- (void)addPosts:(NSSet<PersistencePost *> *)values;
- (void)removePosts:(NSSet<PersistencePost *> *)values;

@end

NS_ASSUME_NONNULL_END
