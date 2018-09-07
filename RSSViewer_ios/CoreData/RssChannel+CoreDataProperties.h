//
//  RssChannel+CoreDataProperties.h
//
//
//  Created by Ruslan Mavlyutov on 07/09/2018.
//
//

#import "RssChannel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RssChannel (CoreDataProperties)

+ (NSFetchRequest<RssChannel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *descriptionChannel;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *urlChannel;

@end

NS_ASSUME_NONNULL_END
