//
//  RssPost+CoreDataProperties.h
//  
//
//  Created by Ruslan Mavlyutov on 13/09/2018.
//
//

#import "RssPost+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RssPost (CoreDataProperties)

+ (NSFetchRequest<RssPost *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *descriptionPost;
@property (nullable, nonatomic, copy) NSString *pubDate;
@property (nullable, nonatomic, copy) NSString *guid;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, retain) RssChannel *whichRssChannel;

@end

NS_ASSUME_NONNULL_END
