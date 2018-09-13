#import "RSSParser.h"
#import "Channel.h"
#import "Post.h"

NSString* reloadChannelNotification = @"reloadChannelNotification";
NSString* IndicatorRSSNotification = @"IndicatorRSSNotification";

static NSString *const channelElementName = @"channel";
static NSString *const itemElementName = @"item";

@interface RSSParser() <NSXMLParserDelegate>

@property (strong, nonatomic) dispatch_queue_t parsingQueue;
@property (nonatomic, assign) id currentElement;
@property (nonatomic, retain) NSMutableString *currentElementData;
@property (nonatomic, retain) DomainChannel *feedChannel;

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

- (void)parserRss: (NSURL *) url : (NSData *)rss completion:(void (^)(DomainChannel *, NSError *, NSString *))completion
{
    urlChannel = url;
    parser = [[NSXMLParser alloc] initWithData:rss];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(self.feedChannel, nil, nil);
    });
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    element = elementName;

    if([element isEqualToString: channelElementName]) {

        DomainChannel *channel = [[DomainChannel alloc] init];
        if(channel.urlChannel.absoluteString.length == 0)
            channel.urlChannel = urlChannel;
        feedChannel = channel;
        currentElement = channel;
        feedChannel.posts = [[NSArray alloc] init];
        return;
    }

    if ([element isEqualToString:itemElementName]) {

        DomainPost *post = [[DomainPost alloc] init];
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
