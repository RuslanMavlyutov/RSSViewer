#import "RssUrlParser.h"

@implementation RssUrlParser

static NSString *const partPrefix = @"https://";
static NSString *const fullPrefix = @"https://www.";

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (NSString *) checkUrlWithString : (NSString *) urlStr error: (NSError**) error
{
    if([urlStr length] > 3) {
        urlStr = [self addMissPrefixString:urlStr];
    } else {
        NSString *domain = @"ErrorDomain";
        NSString *desc = NSLocalizedString(@"Not Valid link", @"");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        *error = [NSError errorWithDomain:domain code:-101 userInfo:userInfo];
    }

    return urlStr;
}

- (NSString *) addMissPrefixString : (NSString *) link
{
    NSString *firstSymbols;
    firstSymbols = [link substringToIndex:3];

    if(![firstSymbols isEqualToString:@"htt"]) {
        if([firstSymbols isEqualToString:@"www"]) {
            link = [partPrefix stringByAppendingString:link];
        } else {
            link = [fullPrefix stringByAppendingString:link];
        }
    }
    return link;
}

@end
