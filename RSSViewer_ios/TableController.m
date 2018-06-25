#import "TableController.h"
#import "DetailViewController.h"

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

- (id)init
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"reloadNotification"
                                               object:nil];

//    [self performSegueWithIdentifier:@"TableController" sender:self];
//    [self performSegueWithIdentifier:@"tableId" sender:self];

    return self;
}

-(void) reloadTable:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    tableFeeds = [dict valueForKey:@"feeds"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    cell.textLabel.text = [[tableFeeds objectAtIndex:indexPath.row] objectForKey:titleName];
    return cell;
}

-(void) reloadTableView
{
    [self.tableView reloadData];
//    UIViewController *vc = self.window.rootViewController;
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
    NSString *string = [tableFeeds[indexPath.row] objectForKey:@"link"];
    NSArray *list = [string componentsSeparatedByString:@" "];
    NSString *firstItem = [list[0] stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    NSDictionary *dict = [NSDictionary dictionaryWithObject:firstItem forKey:@"firstItem"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadWebLink" object:nil userInfo:dict];
}

@end
