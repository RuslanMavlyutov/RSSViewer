#import "RSSParser.h"
#import "Post.h"
#include "TableController.h"

NSString* reloadChannelNotification = @"reloadChannelNotification";
NSString* IndicatorRSSNotification = @"IndicatorRSSNotification";

static NSString *const channelElementName = @"channel";
static NSString *const itemElementName = @"item";

@interface RSSParser() <NSXMLParserDelegate>

@property (strong, nonatomic) dispatch_queue_t parsingQueue;
@property (nonatomic, assign) id currentElement;
@property (nonatomic, retain) NSMutableString *currentElementData;
@property (nonatomic, retain) Channel *feedChannel;

@end

@implementation RSSParser
{
    NSXMLParser *parser;
    NSString *element;
    NSURL *urlChannel;
}

@synthesize currentElement;
@synthesize currentElementData;
@synthesize feedChannel;

-(id) init
{
    self.parsingQueue = dispatch_queue_create("com.rss.parsing", NULL);

    return self;
}

- (void)parserRss: (NSURL *) url : (NSData *)rss completion:(void (^)(Channel *, NSError *, NSString *))completion
{
    urlChannel = url;
    self->parser = [[NSXMLParser alloc] initWithData:rss];
    [self->parser setDelegate:self];
    [self->parser setShouldResolveExternalEntities:NO];
    [self->parser parse];
    completion(feedChannel, nil, nil);
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    element = elementName;

    if([element isEqualToString: channelElementName]) {

        Channel *channel = [[Channel alloc] init];
        if(channel.urlChannel.absoluteString.length == 0)
            channel.urlChannel = urlChannel;
        feedChannel = channel;
        currentElement = channel;
        feedChannel.posts = [[NSArray alloc] init];
        return;
    }

    if ([element isEqualToString:itemElementName]) {

        Post *post = [[Post alloc] init];
        NSArray *currentPost = [[NSArray alloc] initWithObjects:post, nil];
        feedChannel.posts = [feedChannel.posts arrayByAddingObjectsFromArray:currentPost];
        currentElement = post;
        return;
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    SEL selectorName = NSSelectorFromString(elementName);
    if ([currentElement respondsToSelector:selectorName]) {

    if(![[currentElement valueForKey:elementName] length])
        [currentElement setValue:currentElementData forKey:elementName];
    }

    currentElementData = nil;
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentElementData == nil) {
        currentElementData = [[NSMutableString alloc] init];
    }

    if(![string hasPrefix:@"\n"])
        [currentElementData appendString:string];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isStart"];
    [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];
}

@end
