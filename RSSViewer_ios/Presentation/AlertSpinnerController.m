#import "AlertSpinnerController.h"

@implementation AlertSpinnerController

-(void) startAnimateIndicator
{
    UIAlertController *pending = [UIAlertController alertControllerWithTitle:nil
                                                                     message:@"Please wait...\n\n"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor blackColor];
    indicator.translatesAutoresizingMaskIntoConstraints=NO;
    [pending.view addSubview:indicator];
    NSDictionary *views = @{@"pending" : pending.view, @"indicator" : indicator};

    NSArray *constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
    NSArray *constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray *constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    [pending.view addConstraints:constraints];
    [indicator setUserInteractionEnabled:NO];
    [indicator startAnimating];

    UIViewController *current = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (current.presentedViewController) {
        current = current.presentedViewController;
    }

    [current presentViewController:pending animated:YES completion:nil];
}

-(void) stopAnimateIndicator
{
    UIViewController *current = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (current.presentedViewController) {
        current = current.presentedViewController;
    }

    [current dismissViewControllerAnimated:YES completion:nil];
}

@end
