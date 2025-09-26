#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#if __has_include(<Cordova/CDVPlugin.h>)
#import <Cordova/CDVPlugin.h>
@interface LluNativeScannerBridge : CDVPlugin <WKScriptMessageHandler>
#else
@interface LluNativeScannerBridge : NSObject <WKScriptMessageHandler>
#endif

#if __has_include(<Cordova/CDVPlugin.h>)
// Cordova calls this on plugin load
- (void)pluginInitialize;
#endif

@end


