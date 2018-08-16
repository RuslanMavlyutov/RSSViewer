#import "NSString+Warning.h"

@implementation NSString (Warning)

- (BOOL) isNotEmpty
{
    return self != nil && ![self isEqualToString:@""];
}

@end
