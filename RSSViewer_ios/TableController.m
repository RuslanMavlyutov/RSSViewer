#import "TableController.h"
#import "DetailViewController.h"
#import "Post.h"

static NSString* const cellName = @"cell";
static NSString* const titleName = @"title";
static NSString* const linkName = @"link";

@interface TableController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TableController
{
    NSMutableArray *tableFeeds;
}

@synthesize parserFeed, posts;

- (id)init
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"reloadNotification"
                                               object:nil];

    posts = [[NSMutableArray alloc] init];

    return self;
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

-(void) reloadTableView
{
    [self.tableView reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [tableFeeds[indexPath.row] objectForKey:@"link"];
        [[segue destinationViewController] setUrl:string];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *currentPost = [posts objectAtIndex:[indexPath row]];
    NSString *firstItem = [currentPost guid];

    NSDictionary *dict = [NSDictionary dictionaryWithObject:firstItem forKey:@"firstItem"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadWebLink" object:nil userInfo:dict];
}

@end
