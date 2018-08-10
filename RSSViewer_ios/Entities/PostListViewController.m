#import "PostListViewController.h"
#import "PostDetailViewController.h"
#import "Post.h"
#import "NSString+Warning.h"
#import "ExtScope.h"

static NSString* const cellName = @"cell";

@interface PostListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PostListViewController
{
    Channel *currentChannel;
    RSSFeedModel* rssFeedModel;
    UIRefreshControl *refreshControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void) updateRssModel
{
    @weakify(self);
    [rssFeedModel loadRSSWithUrl:currentChannel.urlChannel completion:^(Channel *channel, NSError *error, NSString *warning) {
        @strongify(self);
        if(warning.isEmpty)
            [self alertMessage:warning];
        if(channel) {
            self->currentChannel = channel;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->refreshControl endRefreshing];
                [self.tableView reloadData];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->refreshControl endRefreshing];
        });
    }];
}

- (void) refreshTable
{
    [self updateRssModel];
}

- (void) showChannel : (Channel *) channel : (RSSFeedModel *) feedModel
{
    currentChannel = channel;
    rssFeedModel = feedModel;

    [self.tableView reloadData];
}

- (void) alertMessage : (NSString *) warning
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Warning:"
                                          message:warning
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *actionOK = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                               }];

    [alertController addAction:actionOK];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[currentChannel posts] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];

    cell.textLabel.text = [[[currentChannel posts] objectAtIndex:row] title];
    cell.detailTextLabel.text = [[[currentChannel posts] objectAtIndex:row] description];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strLink = [[[currentChannel posts] objectAtIndex:[indexPath row]] guid];

    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostDetailViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"detail"];
    [self.navigationController pushViewController:vc animated:YES];
    [vc view];
    [vc loadLink:strLink];
}

@end
