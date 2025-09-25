#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <Cordova/CDVPlugin.h>

@interface LluNativeScannerBridge : CDVPlugin <WKScriptMessageHandler>

// Cordova calls this on plugin load
- (void)pluginInitialize;

@end


