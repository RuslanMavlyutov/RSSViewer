#import "UIViewController+AlertMessage.h"

@implementation UIViewController (AlertMessage)

- (void) showErrorMessage : (NSString *) warning
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

@end
