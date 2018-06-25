#import "ParserController.h"
#include "TableController.h"
#include "DetailViewController.h"

NSString* reloadNotification = @"reloadNotification";
NSString* IndicatorRSSNotification = @"IndicatorRSSNotification";

static NSString* const startChannelRss = @"https://developer.apple.com/news/rss/news.rss";
//static NSString* const startChannelRss = @"https://www.kommersant.ru/rss/regions/irkutsk.xml";
static NSString* const itemElementName = @"item";
static NSString* const titleElementName = @"title";
static NSString* const linkElementName = @"link";

@interface ParserController () <NSXMLParserDelegate> {
    IBOutlet UITextField *urlField;
    IBOutlet UILabel *warningLabel;
}
- (IBAction)loadUrl:(id)sender;
- (void) loadParser : (NSURL*) url;
@property (nonatomic, assign) BOOL warningState;

@end

@implementation ParserController
{
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSString *element;
    NSError *m_error;
}

- (id)init
{
    feeds = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    feeds = [[NSMutableArray alloc] init];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    element = elementName;
    if([element isEqualToString: itemElementName]) {

        item = [[NSMutableDictionary alloc] init];
        title = [[NSMutableString alloc] init];
        link = [[NSMutableString alloc] init];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:itemElementName]) {
        [item setObject:title forKey:titleElementName];
        [item setObject:link forKey:linkElementName];

        [feeds addObject:[item copy]];
    }
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([element isEqualToString:titleElementName]) {
        [title appendString:string];
    } else if([element isEqualToString:linkElementName]) {
        [link appendString:string];
    }
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:feeds forKey:@"feeds"];
    [[NSNotificationCenter defaultCenter] postNotificationName:reloadNotification object:nil userInfo:dict];

    NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isStart"];
    [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];
}

- (IBAction)loadUrl:(id)sender
{
    NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isStart"];
    [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];

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
                NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isStart"];
                [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];
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
                    NSDictionary *dictIndicator = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isStart"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:IndicatorRSSNotification object:nil userInfo:dictIndicator];
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
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"table"];

    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"table" source:self destination:navController];
    [self prepareForSegue:segue sender:self];

    if(feeds != nil)
        [feeds removeAllObjects];

    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

@end
