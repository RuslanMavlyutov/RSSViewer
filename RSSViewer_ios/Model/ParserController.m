#import "ParserController.h"
#include "TableController.h"
#include "DetailViewController.h"
#import "Channel.h"
#import "Post.h"

NSString* reloadNotification = @"reloadNotification";
//NSString* IndicatorRSSNotification = @"IndicatorRSSNotification";

static NSString *const channelElementName = @"channel";
static NSString *const itemElementName = @"item";

@interface ParserController () <NSXMLParserDelegate> {
    IBOutlet UITextField *urlField;
    IBOutlet UILabel *warningLabel;
    Channel *feedChannel;
    NSMutableString *currentElementData;
}

- (IBAction)loadUrl:(id)sender;

@property (nonatomic, assign) BOOL warningState;
@property (nonatomic, retain) Channel *feedChannel;
@property (nonatomic, assign) id currentElement;
@property (nonatomic, retain) NSMutableString *currentElementData;

@end

@implementation ParserController
{
    NSXMLParser *parser;
    NSString *element;
}

@synthesize feedChannel;
@synthesize feedPosts;
@synthesize currentElement;
@synthesize currentElementData;
@synthesize isRssChannelUpdate;
@synthesize titleArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    feedPosts = [[NSMutableArray alloc] init];
}

- (id) init
{
    isRssChannelUpdate = false;
    feedPosts = [[NSMutableArray alloc] init];

    return self;
}

-(id)initWithLink : (NSURL*) url
{
    isRssChannelUpdate = true;
    [self updateParser:url];

    return self;
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
    NSDictionary *dict = [NSDictionary dictionaryWithObject:feedPosts forKey:@"feeds"];
    [[NSNotificationCenter defaultCenter] postNotificationName:reloadNotification object:nil userInfo:dict];

//    NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isStart"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];
}

- (IBAction)loadUrl:(id)sender
{
//    NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isStart"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];

    [warningLabel setText:@""];
    NSString *string = urlField.text;
    NSURL *url = [NSURL URLWithString:string];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [self setWarningState:NO];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if(error) {
            [self setWarningState:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->warningLabel setText:@"Page can't be found"];
//                NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isStart"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];
            });
        } else {
            NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
            if(statusCode != 404) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->warningLabel setText:@""];
                });
            } else {
                NSString *warning = [NSString stringWithFormat:@"The url is invalid! - %ld", (long)statusCode];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->warningLabel setText: warning];
//                    NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isStart"];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];
                });
                [self setWarningState:YES];
            }
        }
        if(!self.warningState) {
            dispatch_async(dispatch_get_main_queue(), ^{
            [self loadParser:url];
            });
        }
    }];
    [dataTask resume];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"test");
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TableController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"table"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) loadParser : (NSURL*) url
{
    if(feedPosts != nil)
        [feedPosts removeAllObjects];

    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

-(void) updateParser: (NSURL*) url
{
    dispatch_queue_t reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(reentrantAvoidanceQueue, ^{
        self->parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [self->parser setDelegate:self];
        [self->parser setShouldResolveExternalEntities:NO];
        [self->parser parse];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{});
}

@end
