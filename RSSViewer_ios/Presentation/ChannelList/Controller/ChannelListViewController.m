#import "ChannelListViewController.h"
#import "PostListViewController.h"
#import "RSSLoader.h"
#import "RSSParser.h"
#import "RSSFeedModel.h"
#import "AlertSpinnerController.h"
#import "NSString+Warning.h"
#import "UIViewController+AlertMessage.h"
#import "ChannelCell.h"
#import "ExtScope.h"
#import "RssUrlParser.h"
#import "PersistanceStorage.h"

static NSString *const firstChannelRss = @"https://developer.apple.com/news/rss/news.rss";
static NSString *const secondChannelRss = @"https://www.kommersant.ru/rss/regions/irkutsk.xml";
static NSString *const thirdChannelRss = @"https://www.kommersant.ru/rss/regions/saratov.xml";
static NSString *const fourthChannelRss = @"https://habr.com/rss/interesting";
static NSString *const fivethChannelRss = @"https://lenta.ru/rss/news";
static NSString *const mainSettings = @"settings";
NSString* reloadNotification = @"reloadNotification";

@implementation ChannelListViewController {
    NSArray<DomainChannel *> *channels;
    NSArray<NSString *> *linkArray;
    NSArray<NSURL *> *urlArray;
    RSSFeedModel *rssFeedModel;
    RssUrlParser *rssUrlParser;
    AlertSpinnerController *alertSpinner;
    CoreDataPersistanceStorage *storage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    urlArray = [[NSArray alloc] init];
//    linkArray = [defaults arrayForKey:mainSettings];
//    channels = [[NSArray alloc] init];
    rssUrlParser = [[RssUrlParser alloc] init];
    alertSpinner = [[AlertSpinnerController alloc] init];
    storage = [[CoreDataPersistanceStorage alloc] init];
//    if(!linkArray)
//        linkArray = [NSMutableArray arrayWithObjects:firstChannelRss, secondChannelRss, thirdChannelRss, nil];

    RSSParser *parser = [[RSSParser alloc] init];
    RSSLoader *loader = [[RSSLoader alloc] init];
    rssFeedModel = [[RSSFeedModel alloc] initWithLoader:loader parser:parser];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(ChannelCell.class) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass(ChannelCell.class)];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;

    [storage fetchAllChannels:^(NSArray<DomainChannel *> *result, NSError *error) {
        if(error) {
            NSLog(@"Error while fetching:\n%@",
                  ([error localizedDescription] != nil) ?
                  [error localizedDescription] : @"Unknown Error");
        }
        if(result)
            self->channels = result;
    }];

//    for(int i = 0; i < linkArray.count; i++) {
//        NSURL *url = [NSURL URLWithString:linkArray[i]];
//        [self loadRSSChannel:url];
//    }
//    [alertSpinner startAnimateIndicator];
}

- (void) loadRSSChannel : (NSURL *) url
{
    @weakify(self);
    [rssFeedModel loadRSSWithUrl:url completion:^(DomainChannel *channel, NSError *error, NSString *warning) {
        @strongify(self);
        if(warning.isNotEmpty)
            [self dismissViewControllerAnimated:YES completion:^{[self showErrorMessage:warning];}];
        if(channel) {
            NSArray *arrayChannel = [[NSArray alloc] initWithObjects:channel, nil];
            self->channels = [self->channels arrayByAddingObjectsFromArray:arrayChannel];
            NSArray *arrayUrl = [[NSArray alloc] initWithObjects:url, nil];
            self->urlArray = [self->urlArray arrayByAddingObjectsFromArray:arrayUrl];
            if(![self->linkArray containsObject:url.absoluteString]) {
                [self->storage saveChannel:channel completion:^(NSError *error) {
                    if(error) {
                        NSLog(@"%@",error);
                    } else {
                        [self saveSettings:url];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }];
            }
//            if(self->channels.count == self->linkArray.count) {
//                NSMutableArray *tempUrl = [[NSMutableArray alloc] init];
//                NSMutableArray *tempChannel = [[NSMutableArray alloc] init];
//                for(int i = 0; i <  self->urlArray.count; i++) {
//                    int index = 0;
//                    for(NSURL* url in self->urlArray) {
//                        if([self->linkArray[i] isEqual: url.absoluteString]) {
//                            [tempUrl addObject:url];
//                            [tempChannel addObject:self->channels[index]];
//                        }
//                        index++;
//                    }
//                }
//                self->urlArray = [[NSMutableArray alloc] initWithArray:tempUrl];
//                self->channels = [[NSArray alloc] initWithArray:tempChannel];
//                [self.tableView reloadData];
//                [self->alertSpinner stopAnimateIndicator];
//            }
            [self->alertSpinner stopAnimateIndicator];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *cell = (ChannelCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ChannelCell.class)];
    [cell configureForChannel:[channels objectAtIndex:indexPath.row]];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [channels count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostListViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"table"];
    [self.navigationController pushViewController:vc animated:YES];

    DomainChannel *selectedChannel = [channels objectAtIndex:indexPath.row];
    [vc showChannel:selectedChannel : rssFeedModel];
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
        NSMutableArray *urlMutableArray = [NSMutableArray arrayWithArray:urlArray];
        [urlMutableArray removeObjectAtIndex:indexPath.row];
        urlArray = [NSArray arrayWithArray:urlMutableArray];
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

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
         textField.placeholder = @"https://www.";
     }];

    UIAlertAction *actionCancel = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];

    UIAlertAction *actionOK = [UIAlertAction
                               actionWithTitle:@"Add"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   UITextField *link = alertController.textFields.firstObject;
                                   [self addRssLink:[link text]];
                               }];

    [alertController addAction:actionCancel];
    [alertController addAction:actionOK];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) addRssLink:(NSString *) link
{
    NSError *error = NULL;
    link = [rssUrlParser checkUrlWithString:link error:&error];

    if([linkArray containsObject:link]) {
        [self showErrorMessage:@"This rss channel already esists!"];
        return;
    }

    NSURL *url = [NSURL URLWithString:link];
    if(error) {
        [self showErrorMessage:@"Not valid link!"];
        NSLog(@"error");
        return;
    }

    [alertSpinner startAnimateIndicator];
    [self loadRSSChannel:url];
}

- (void) saveSettings : (NSURL *) url
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:linkArray];
    [array addObject:url.absoluteString];
    linkArray = [NSArray arrayWithArray:array];

//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:linkArray forKey:mainSettings];
//    [defaults synchronize];
}

@end
