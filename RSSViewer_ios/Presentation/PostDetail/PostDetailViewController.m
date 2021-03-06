#import "PostDetailViewController.h"

@interface PostDetailViewController ()

@property (strong, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation PostDetailViewController

@synthesize urlStr;

-(void) viewWillAppear:(BOOL)animated
{
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
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
