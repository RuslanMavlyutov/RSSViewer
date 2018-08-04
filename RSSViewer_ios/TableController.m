#import "TableController.h"
#import "DetailViewController.h"
#import "Post.h"

static NSString* const cellName = @"cell";
static NSString* const titleName = @"title";
static NSString* const linkName = @"link";

@interface TableController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation TableController
{
    NSMutableArray *tableFeeds;
}

@synthesize posts;

- (void) loadNews : (NSArray *) array
{
    posts = [[NSMutableArray alloc] init];
    tableFeeds = [[NSMutableArray alloc] initWithArray:array];
    for (Post *feedPost in tableFeeds) {
        [posts addObject:feedPost];
    }

    [self.tableView reloadData];
}

-(void) reloadTable:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    tableFeeds = [dict valueForKey:@"feeds"];
    for (Post *feedPost in tableFeeds) {
        [posts addObject:feedPost];
    }

    [self.tableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableFeeds.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];

    Post *currentPost = [posts objectAtIndex:row];
    cell.textLabel.text = [currentPost title];
    cell.detailTextLabel.text = [currentPost description];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *currentPost = [posts objectAtIndex:[indexPath row]];
    NSString *firstItem = [currentPost guid];

    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"detail"];
    [self.navigationController pushViewController:vc animated:YES];
    [vc view];
    [vc loadLink:firstItem];
}

@end
