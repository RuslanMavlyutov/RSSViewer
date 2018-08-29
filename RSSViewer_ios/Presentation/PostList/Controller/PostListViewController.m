#import "PostListViewController.h"
#import "PostDetailViewController.h"
#import "PostListCell.h"
#import "Post.h"
#import "NSString+Warning.h"
#import "UIViewController+AlertMessage.h"
#import "NSURL+CheckLink.h"
#import "ExtScope.h"

static NSString* const cellName = @"cell";

@interface PostListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PostListViewController
{
    Channel *currentChannel;
    RSSFeedModel* rssFeedModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PostListCell.class) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass(PostListCell.class)];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    [self.tableView.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void) updateRssModel
{
    @weakify(self);
    [rssFeedModel loadRSSWithUrl:currentChannel.urlChannel completion:^(Channel *channel, NSError *error, NSString *warning) {
        @strongify(self);
        if(warning.isNotEmpty)
            [self showErrorMessage:warning];
        if(channel) {
            self->currentChannel = channel;
            [self.tableView.refreshControl endRefreshing];
            [self.tableView reloadData];
        }
        [self.tableView.refreshControl endRefreshing];
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
    PostListCell *cell = (PostListCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(PostListCell.class)];
    [cell configureForPost:[[currentChannel posts] objectAtIndex:row]];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strLink = [[[currentChannel posts] objectAtIndex:[indexPath row]] guid];

    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostDetailViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"detail"];
    [self.navigationController pushViewController:vc animated:YES];

    NSURL *url = [NSURL URLWithString:strLink];
    if(url.isLinkValid) {
        vc.urlStr = strLink;
        return;
    }

    strLink = [[[currentChannel posts] objectAtIndex:[indexPath row]] link];
    url = [NSURL URLWithString:strLink];
    if(url.isLinkValid)
        vc.urlStr = strLink;
}

@end
