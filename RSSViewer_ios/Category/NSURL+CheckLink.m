#import "NSURL+CheckLink.h"

@implementation NSURL (CheckLink)

- (BOOL) isLinkValid;
{
    return self && self.scheme && self.host;
}

@end
