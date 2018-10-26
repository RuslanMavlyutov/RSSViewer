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
#import "PersistenceStorage.h"

static NSString *const firstChannelRss = @"https://developer.apple.com/news/rss/news.rss";
static NSString *const secondChannelRss = @"https://www.kommersant.ru/rss/regions/irkutsk.xml";
static NSString *const thirdChannelRss = @"https://www.kommersant.ru/rss/regions/saratov.xml";
static NSString *const fourthChannelRss = @"https://habr.com/rss/interesting";
static NSString *const fivethChannelRss = @"https://lenta.ru/rss/news";

@implementation ChannelListViewController {
    NSArray<DomainChannel *> *channels;
    RSSFeedModel *rssFeedModel;
    AlertSpinnerController *alertSpinner;
    CoreDataPersistenceStorage *storage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    alertSpinner = [[AlertSpinnerController alloc] init];
    storage = [[CoreDataPersistenceStorage alloc] init];
    [storage loadStorageWithCompletion:^(NSError *error) {
        if(error != nil) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }];

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
        if(result) {
            self->channels = result;
            [self.tableView reloadData];
        }
    }];
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
                [self->storage saveChannel:channel completion:^(NSError *error) {
                    if(error) {
                        NSLog(@"%@",error);
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }];
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
    [vc showChannel:selectedChannel : rssFeedModel withStorage:storage];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [storage removeChannel:[channels objectAtIndex:indexPath.row] completion:^(NSError *error) {
            if(error) {
                NSLog(@"Error while removing:\n%@",
                      ([error localizedDescription] != nil) ?
                      [error localizedDescription] : @"Unknown Error");
            }
        }];
        NSMutableArray *array = [NSMutableArray arrayWithArray:channels];
        [array removeObjectAtIndex:indexPath.row];
        channels = [NSArray arrayWithArray:array];

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
    link = [RssUrlParser checkUrlWithString:link error:&error];
    if(error) {
        [self showErrorMessage:@"Not valid link!"];
        NSLog(@"error");
        return;
    }

    for(DomainChannel *channel in channels) {
        if([channel.urlChannel.absoluteString isEqualToString:link]) {
            [self showErrorMessage:@"This rss channel already esists!"];
            return;
        }
    }

    NSURL *url = [NSURL URLWithString:link];

    [alertSpinner startAnimateIndicator];
    [self loadRSSChannel:url];
}

@end
