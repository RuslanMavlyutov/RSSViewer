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
}

@synthesize feedPosts;
@synthesize currentElement;
@synthesize currentElementData;
@synthesize feedChannel;
@synthesize titleArray;
@synthesize isRssChannelUpdate;

-(id) init
{
    self.parsingQueue = dispatch_queue_create("com.rss.parsing", NULL);
    feedPosts = [[NSMutableArray alloc] init];

    return self;
}

- (void) updateChannel
{
    isRssChannelUpdate = true;
}

- (void)parserRss:(NSData *)rss completion:(void (^)(Channel *, NSError *, NSString *))completion
{
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
        feedChannel = channel;
        currentElement = channel;
        return;
    }

    if ([element isEqualToString:itemElementName]) {

        Post *post = [[Post alloc] init];
        [feedPosts addObject:post];
        currentElement = post;
        return;
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    SEL selectorName = NSSelectorFromString(elementName);
    if ([currentElement respondsToSelector:selectorName]) {

        [currentElement setValue:currentElementData forKey:elementName];
    }

    currentElementData = nil;

    if(isRssChannelUpdate && feedChannel.description != nil) {
        if(!titleArray)
            titleArray = [[NSMutableArray alloc] init];
        [titleArray addObject:feedChannel];
        [parser abortParsing];
    }
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
