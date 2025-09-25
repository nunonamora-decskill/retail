#import <UIKit/UIKit.h>


@protocol PosHardwareDelegate

@required
- (NSDictionary*)hardwareProperties;
- (void)handleNativeCommand:(NSString *)command params:(NSDictionary*)params;

@end
