#import "LluNativeScannerBridge.h"
#import "LluRemoteConfigHelper.h"
#import "LluScreenDetectionHelper.h"

@interface LluNativeScannerBridge()
@property (nonatomic, weak) WKWebView *wkWebView;
@property (nonatomic, assign) BOOL attached;
@end

@implementation LluNativeScannerBridge

#if __has_include(<Cordova/CDVPlugin.h>)
// Cordova lifecycle
- (void)pluginInitialize {
    [super pluginInitialize];
    // CDVWKWebViewEngine exposes an internal WKWebView; Cordova webView may be a wrapper.
    if ([self.webView isKindOfClass:[WKWebView class]]) {
        // In newer Cordova, self.webView is WKWebView
        _wkWebView = (WKWebView *)self.webView;
    } else if ([self.webViewEngine respondsToSelector:@selector(engineWebView)]) {
        // Older engines expose engineWebView
        UIView *view = [self.webViewEngine performSelector:@selector(engineWebView)];
        if ([view isKindOfClass:[WKWebView class]]) {
            _wkWebView = (WKWebView *)view;
        }
    }
    [self attachHandlerIfPossible];
}
#endif

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _wkWebView = webView;
        [self attachHandlerIfPossible];
    }
    return self;
}

- (void)attachHandlerIfPossible {
    if (_wkWebView && !_attached) {
        [_wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"lluscanner"];
        _attached = YES;
    }
}

- (void)onReset {
    // Called when the WebView navigates to a new page or is reloaded
    if (_wkWebView && _attached) {
        [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"lluscanner"];
        _attached = NO;
    }
}

- (void)dispose {
    // Called when the plugin is disposed
    if (_wkWebView && _attached) {
        [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"lluscanner"];
        _attached = NO;
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
        [self.wkWebView evaluateJavaScript:js completionHandler:nil];
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
            [LluScreenDetectionHelper detectModeInWebView:self.wkWebView completion:^(LluScreenMode mode) {
                [self presentLluScanner:inputType isContinuousScan:(mode == LluScreenModeContinuous)];
            }];
        }
    }
}

#pragma mark - Present scanner (stub)

- (void)presentLluScanner:(NSString *)inputType isContinuousScan:(BOOL)isContinuousScan {
    // Present a simple AVFoundation-based scanner
    __weak typeof(self) weakSelf = self;
    void (^presentBlock)(void) = ^{
        UIViewController *root = [weakSelf topViewController];
        if (!root) { return; }
        LluScannerViewController *vc = [LluScannerViewController new];
        vc.continuous = isContinuousScan;
        vc.inputType = inputType;
        vc.onScan = ^(NSDictionary *payload) {
            // Return to JS
            NSError *err = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&err];
            if (!err && data) {
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *js = [NSString stringWithFormat:@"window.__lluScanner && window.__lluScanner.resolve && window.__lluScanner.resolve(%@);", json];
                [weakSelf.wkWebView evaluateJavaScript:js completionHandler:nil];
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
    };
    if ([NSThread isMainThread]) {
        presentBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), presentBlock);
    }
}

- (UIViewController *)topViewController {
    UIViewController *root = nil;
    if (@available(iOS 13.0, *)) {
        NSSet *connectedScenes = UIApplication.sharedApplication.connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) { root = window.rootViewController; break; }
                }
                if (root) { break; }
            }
        }
    }
    if (!root) {
        root = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    while (root.presentedViewController) { root = root.presentedViewController; }
    return root;
}

@end


