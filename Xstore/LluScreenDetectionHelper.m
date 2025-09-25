#import "LluScreenDetectionHelper.h"

@implementation LluScreenDetectionHelper

+ (void)detectModeInWebView:(WKWebView *)webView completion:(void(^)(LluScreenMode mode))completion {
    if (!webView) { if (completion) completion(LluScreenModeSingle); return; }
    NSString *js = @"(function(){try{if(window.__xmobile&&window.__xmobile.getCurrentScreen){return String(window.__xmobile.getCurrentScreen()).toLowerCase();}return String(document.title||'');}catch(e){return '';} })()";
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable value, NSError * _Nullable error) {
        NSString *text = [[value isKindOfClass:[NSString class]] ? value : @""] lowercaseString];
        BOOL isTxn = ([text containsString:@"transaction"] || [text containsString:@"sale"]);
        BOOL isSingle = ([text containsString:@"gift"] || [text containsString:@"return"] || [text containsString:@"refund"]);
        LluScreenMode mode = (isTxn && !isSingle) ? LluScreenModeContinuous : LluScreenModeSingle;
        if (completion) completion(mode);
    }];
}

@end


