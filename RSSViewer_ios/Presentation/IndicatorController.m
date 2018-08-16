#import "IndicatorController.h"

@interface IndicatorController () <UIApplicationDelegate> {
    IBOutlet UIActivityIndicatorView *indicatorRss;
    IBOutlet UIActivityIndicatorView *indicator;
}

-(void) switchIndicatorRSSProgress : (bool) isIndicatorOn;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animationForLoadRss:)
                                                 name:@"IndicatorRSSNotification"
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

-(void) animationForLoadRss:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber* isStart = [dict valueForKey:@"isStart"];
    [self switchIndicatorRSSProgress:[isStart boolValue]];
}

-(void) startAnimationIndicator
{
    [indicatorRss startAnimating];
    indicator.hidden = NO;
}

-(void) stopAnimationIndicator
{
    [indicator stopAnimating];
    indicator.hidden = YES;
}

-(void) switchIndicatorRSSProgress : (bool) isIndicatorOn
{
    if(isIndicatorOn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->indicatorRss startAnimating];
            self->indicatorRss.hidden = NO;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->indicatorRss stopAnimating];
            self->indicatorRss.hidden = YES;
        });
    }
}

@end
