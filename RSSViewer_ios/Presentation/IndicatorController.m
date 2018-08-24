#import "IndicatorController.h"

@interface IndicatorController () <UIApplicationDelegate> {
    IBOutlet UIActivityIndicatorView *indicator;
}

-(void) startAnimationIndicator;
-(void) stopAnimationIndicator;

@end

@implementation IndicatorController

- (id)init
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animationForLoadWebView:)
                                                 name:@"IndicatorNotification"
                                               object:nil];
    return self;
}

-(void) animationForLoadWebView:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSString *str = [dict valueForKey:@"str"];
    if([str isEqualToString:@"stop"]) {
        [self stopAnimationIndicator];
    } else if ([str isEqualToString:@"start"]) {
        [self startAnimationIndicator];
    }
}

-(void) startAnimationIndicator
{
    [indicator startAnimating];
    indicator.hidden = NO;
}

-(void) stopAnimationIndicator
{
    [indicator stopAnimating];
    indicator.hidden = YES;
}

@end
