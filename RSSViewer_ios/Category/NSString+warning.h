#import <Foundation/Foundation.h>

@interface NSString (warning)

- (BOOL) isEmpty;

@end

@implementation NSString (warning)

- (BOOL) isEmpty
{
    return self != nil && ![self isEqualToString:@""];
}

@end
