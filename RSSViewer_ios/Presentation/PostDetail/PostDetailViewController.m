#import "PostDetailViewController.h"

@interface PostDetailViewController ()

@property (strong, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation PostDetailViewController

-(void) loadLink: (NSString *) urlString
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"loading"]) {
        if(!self.webView.isLoading) {
            NSString *str = @"stop";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:str forKey:@"str"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IndicatorNotification" object:nil userInfo:dict];
        }
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSString *str = @"start";
        NSDictionary *dict = [NSDictionary dictionaryWithObject:str forKey:@"str"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IndicatorNotification" object:nil userInfo:dict];
    }
}

@end
