#import "LluNativeScannerBridge.h"
#import "LluRemoteConfigHelper.h"
#import "LluScreenDetectionHelper.h"

@interface LluNativeScannerBridge()
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, assign) BOOL attached;
@end

@implementation LluNativeScannerBridge

// Cordova lifecycle
- (void)pluginInitialize {
    [super pluginInitialize];
    // CDVWKWebViewEngine exposes an internal WKWebView; Cordova webView may be a wrapper.
    if ([self.webView isKindOfClass:[WKWebView class]]) {
        // In newer Cordova, self.webView is WKWebView
        _webView = (WKWebView *)self.webView;
    } else if ([self.webViewEngine respondsToSelector:@selector(engineWebView)]) {
        // Older engines expose engineWebView
        UIView *view = [self.webViewEngine performSelector:@selector(engineWebView)];
        if ([view isKindOfClass:[WKWebView class]]) {
            _webView = (WKWebView *)view;
        }
    }
    if (_webView && !_attached) {
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"lluscanner"];
        _attached = YES;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.name isEqualToString:@"lluscanner"]) { return; }
    if (![message.body isKindOfClass:[NSDictionary class]]) { return; }
    NSDictionary *dict = (NSDictionary *)message.body;
    NSString *action = dict[@"action"];
    if ([action isEqualToString:@"getScannerMode"]) {
        BOOL newScanner = [LluRemoteConfigHelper isNewScannerEnabled];
        NSString *mode = newScanner ? @"native" : @"legacy";
        NSString *js = [NSString stringWithFormat:@"window.__lluScanner && window.__lluScanner.resolveMode && window.__lluScanner.resolveMode('%@');", mode];
        [self.webView evaluateJavaScript:js completionHandler:nil];
    } else if ([action isEqualToString:@"scan"]) {
        NSDictionary *options = dict[@"options"];
        NSString *inputType = nil;
        BOOL hasContinuous = NO;
        BOOL isContinuous = NO;

        if ([options isKindOfClass:[NSDictionary class]]) {
            id inputTypeValue = options[@"inputType"]; // e.g., "barcode", "qrcode", "giftcard"
            if ([inputTypeValue isKindOfClass:[NSString class]]) {
                inputType = (NSString *)inputTypeValue;
            }
            id continuousValue = options[@"continuous"]; // boolean hint from JS
            if ([continuousValue isKindOfClass:[NSNumber class]]) {
                hasContinuous = YES;
                isContinuous = [(NSNumber *)continuousValue boolValue];
            }
        }

        if (hasContinuous) {
            [self presentLluScanner:inputType isContinuousScan:isContinuous];
        } else {
            [LluScreenDetectionHelper detectModeInWebView:self.webView completion:^(LluScreenMode mode) {
                [self presentLluScanner:inputType isContinuousScan:(mode == LluScreenModeContinuous)];
            }];
        }
    }
}

- (BOOL)isNewScannerEnabled {
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

#pragma mark - Present scanner (stub)

- (void)presentLluScanner:(NSString *)inputType isContinuousScan:(BOOL)isContinuousScan {
    // Present a simple AVFoundation-based scanner
    UIViewController *root = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (root.presentedViewController) { root = root.presentedViewController; }
    LluScannerViewController *vc = [LluScannerViewController new];
    vc.continuous = isContinuousScan;
    __weak typeof(self) weakSelf = self;
    vc.onScan = ^(NSDictionary *payload) {
        // Return to JS
        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&err];
        if (!err && data) {
            NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *js = [NSString stringWithFormat:@"window.__lluScanner && window.__lluScanner.resolve && window.__lluScanner.resolve(%@);", json];
            [weakSelf.webView evaluateJavaScript:js completionHandler:nil];
        }
        // Forward to server
        Class apiClass = NSClassFromString(@"PosHardwareAPI");
        if (apiClass && [apiClass respondsToSelector:@selector(sharedInstance)]) {
            id api = [apiClass performSelector:@selector(sharedInstance)];
            if ([api respondsToSelector:@selector(postHardwareEvent:eventData:)]) {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [api performSelector:@selector(postHardwareEvent:eventData:) withObject:@"kCordovaCameraBarcodeScanner" withObject:payload];
                #pragma clang diagnostic pop
            }
        }
    };
    vc.onClose = ^{
        // no-op
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [root presentViewController:nav animated:YES completion:nil];
}

@end


