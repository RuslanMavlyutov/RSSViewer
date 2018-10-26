#import "PersistencePost+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PersistencePost (CoreDataProperties)

+ (NSFetchRequest<PersistencePost *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *descriptionPost;
@property (nullable, nonatomic, copy) NSString *guid;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *pubDate;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) PersistenceChannel *channel;

@end

NS_ASSUME_NONNULL_END
