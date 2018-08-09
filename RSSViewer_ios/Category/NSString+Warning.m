#import "NSString+Warning.h"

@implementation NSString (Warning)

- (BOOL) isEmpty
{
    return self != nil && ![self isEqualToString:@""];
}

@end
