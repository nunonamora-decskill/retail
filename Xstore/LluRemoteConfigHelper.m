#import "LluRemoteConfigHelper.h"

@implementation LluRemoteConfigHelper

+ (BOOL)isNewScannerEnabled {
    NSDictionary *managed = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.apple.configuration.managed"] ?: @{};
    id feature = managed[@"feature"];
    if ([feature isKindOfClass:[NSDictionary class]]) {
        NSNumber *flag = ((NSDictionary *)feature)[@"newScanner"];
        if ([flag isKindOfClass:[NSNumber class]]) { return [flag boolValue]; }
    }
    NSNumber *flat = managed[@"feature.newScanner"];
    if ([flat isKindOfClass:[NSNumber class]]) { return [flat boolValue]; }
    return NO;
}

@end


