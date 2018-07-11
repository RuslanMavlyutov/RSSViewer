#import "ChannelListViewController.h"
#import "ParserController.h"
#import "TableController.h"

#import "RSSLoader.h"
#import "RSSParser.h"
#import "RSSFeedModel.h"
#import "Channel.h"

static NSString *const firstChannelRss = @"https://developer.apple.com/news/rss/news.rss";
static NSString *const secondChannelRss = @"https://www.kommersant.ru/rss/regions/irkutsk.xml";
static NSString *const thirdChannelRss = @"https://www.kommersant.ru/rss/regions/saratov.xml";
static NSString *const fourthChannelRss = @"https://habr.com/rss/interesting";
static NSString *const fivethChannelRss = @"https://lenta.ru/rss/news";
static NSString *const mainSettings = @"settings";

@implementation ChannelListViewController {
    NSArray *channels;
    NSArray *linkArray;
    NSMutableArray *urlArray;
    NSURL *url;
    ParserController *parser;
    RSSLoader *loader;
    RSSParser *parserN;
    RSSFeedModel *rssFeedModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    urlArray = [[NSMutableArray alloc] init];
    linkArray = [defaults arrayForKey:mainSettings];

    if(!linkArray)
        linkArray = [NSMutableArray arrayWithObjects:firstChannelRss, secondChannelRss, thirdChannelRss, nil];

    loader = [[RSSLoader alloc] init];
    parserN = [[RSSParser alloc] init];
    rssFeedModel = [[RSSFeedModel alloc] initWithLoader:loader parser:parserN];

    for(int i = 0; i < linkArray.count; i++) {
        url = [NSURL URLWithString:linkArray[i]];
        [self loadRSSChannel:url];
    }
//    parser = [ParserController alloc];
//
//    for(int i = 0; i < linkArray.count; i++) {
//        url = [NSURL URLWithString:linkArray[i]];
//        channels = nil;
//        channels = [NSArray arrayWithArray:[[parser initWithLink:url] titleArray]];
//    }
}

- (void) loadRSSChannel : (NSURL *) url
{
    [rssFeedModel loadRSSWithUrl:url completion:^(Channel *channel, NSError *error, NSString *warning) {
        if(![warning isEqualToString:@""] && warning != nil) {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Warning:"
                                                  message:warning
                                                  preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *actionOK = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                       }];

            [alertController addAction:actionOK];

            [self presentViewController:alertController animated:YES completion:nil];
        }
        if(channel) {
            self->channels = [NSArray arrayWithArray:[self->parserN titleArray]];
            [self->urlArray addObject:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdenitifier = @"simpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdenitifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdenitifier];
    }

    cell.textLabel.text = [[channels objectAtIndex:indexPath.row] title];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [channels count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TableController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"table"];
    [self.navigationController pushViewController:vc animated:YES];

    ParserController *parserController = [[ParserController alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@", [urlArray objectAtIndex:indexPath.row]];
    NSURL *url = [NSURL URLWithString:str];
    [parserController loadParser:url];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:linkArray];
        [array removeObjectAtIndex:indexPath.row];
        linkArray = [NSArray arrayWithArray:array];
        array = [NSMutableArray arrayWithArray:channels];
        [array removeObjectAtIndex:indexPath.row];
        channels = [NSArray arrayWithArray:array];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:linkArray forKey:mainSettings];
        [defaults synchronize];

        [tableView reloadData];
    }
}

- (IBAction)addRssChanel:(UIBarButtonItem *)sender
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Add rss link:"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"https://www.";
     }];

    UIAlertAction *actionCancel = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];

    UIAlertAction *actionOK = [UIAlertAction
                               actionWithTitle:@"Add"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *link = alertController.textFields.firstObject;

                                   [self addRssLink:[link text]];
                               }];

    [alertController addAction:actionCancel];
    [alertController addAction:actionOK];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) addRssLink:(NSString *) link
{
    NSLog(@"Link: %@", link);

    // TODO: check link error

    if([linkArray containsObject:link])
        return;

    NSMutableArray *array = [NSMutableArray arrayWithArray:linkArray];
    [array addObject:link];
    linkArray = [NSArray arrayWithArray:array];
    url = [NSURL URLWithString:link];
    channels = [NSArray arrayWithArray:[[parser initWithLink:url] titleArray]];
    [self.tableView reloadData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:linkArray forKey:mainSettings];
    [defaults synchronize];
}

@end
