#import "TableController.h"
#import "DetailViewController.h"
#import "Post.h"

static NSString* const cellName = @"cell";

@interface TableController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation TableController
{
    Channel *currentChannel;
}

- (void) showChannel : (Channel *) channel
{
    currentChannel = channel;

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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];

    cell.textLabel.text = [[[currentChannel posts] objectAtIndex:row] title];
    cell.detailTextLabel.text = [[[currentChannel posts] objectAtIndex:row] description];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strLink = [[[currentChannel posts] objectAtIndex:[indexPath row]] guid];

    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"detail"];
    [self.navigationController pushViewController:vc animated:YES];
    [vc view];
    [vc loadLink:strLink];
}

@end
