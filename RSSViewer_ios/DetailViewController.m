#import "DetailViewController.h"
#import "TableController.h"
#import "ParserController.h"

@interface DetailViewController ()

@property (strong, nonatomic) IBOutlet WKWebView *webView;

- (IBAction)backToPreviousScreen:(id)sender;
-(void) backBtn;

@end

@implementation DetailViewController {
    TableController *table;
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) loadWebLink:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSString *firstItem = [dict valueForKey:@"firstItem"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:firstItem]]];
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadWebLink:)
                                                 name:@"loadWebLink"
                                               object:nil];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backToPreviousScreen:(id)sender
{
    [self backBtn];
}

-(void)backBtn
{
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
