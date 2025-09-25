#import "PosHardwareDelegate.h"

@interface PosHardwareAPI : NSObject

+(PosHardwareAPI *) sharedInstance;

-(void)setPosHardwareDelegate:(id<PosHardwareDelegate>)delegate;

-(void)postHardwareEvent:(NSString*) eventId eventData:(NSDictionary*)eventData;

@end
