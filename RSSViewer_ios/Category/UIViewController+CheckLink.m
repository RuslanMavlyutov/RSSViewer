#import "UIViewController+CheckLink.h"

@implementation UIViewController (CheckLink)

- (BOOL) isLinkValid : (NSURL *) link
{
    return link && link.scheme && link.host;
}

@end
