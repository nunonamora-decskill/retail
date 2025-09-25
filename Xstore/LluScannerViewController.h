#import <UIKit/UIKit.h>

typedef void(^LluScannerResult)(NSDictionary *payload);
typedef void(^LluScannerClosed)(void);

@interface LluScannerViewController : UIViewController

// If YES, keep scanning and invoke onScan for each detection. Caller dismisses.
// If NO, stop after first result, invoke onScan once, and auto-dismiss.
@property (nonatomic, assign) BOOL continuous;
@property (nonatomic, copy) LluScannerResult onScan;
@property (nonatomic, copy) LluScannerClosed onClose;

@end


