#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef NS_ENUM(NSInteger, LluScreenMode) {
    LluScreenModeSingle,
    LluScreenModeContinuous
};

@interface LluScreenDetectionHelper : NSObject
+ (void)detectModeInWebView:(WKWebView *)webView completion:(void(^)(LluScreenMode mode))completion;
@end


