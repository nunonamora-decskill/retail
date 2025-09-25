#import "LluScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LluScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation LluScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupCamera];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
}

- (void)dealloc {
    [self.session stopRunning];
}

- (void)setupCamera {
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input || error) { [self closeDueToError:error]; return; }
    if ([self.session canAddInput:input]) { [self.session addInput:input]; }

    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:output]) { [self.session addOutput:output]; }
    dispatch_queue_t queue = dispatch_get_main_queue();
    [output setMetadataObjectsDelegate:self queue:queue];
    output.metadataObjectTypes = output.availableMetadataObjectTypes; // QR, EAN, UPC, etc.

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];

    [self.session startRunning];
}

- (void)metadataOutput:(AVCaptureMetadataOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count == 0) { return; }
    AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)metadataObjects.firstObject;
    if (![obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) { return; }
    NSString *value = obj.stringValue ?: @"";
    NSString *type = obj.type ?: @"";

    NSDictionary *payload = @{ @"text": value, @"format": [self humanReadable:type] };
    if (self.onScan) { self.onScan(payload); }

    if (!self.continuous) {
        [self.session stopRunning];
        [self dismissViewControllerAnimated:YES completion:^{ if (self.onClose) self.onClose(); }];
    }
}

- (NSString *)humanReadable:(AVMetadataObjectType)type {
    // Map a few common types; otherwise return raw type string
    if ([type isEqualToString:AVMetadataObjectTypeQRCode]) return @"QR";
    if ([type isEqualToString:AVMetadataObjectTypeEAN13Code]) return @"EAN_13";
    if ([type isEqualToString:AVMetadataObjectTypeEAN8Code]) return @"EAN_8";
    if ([type isEqualToString:AVMetadataObjectTypeCode128Code]) return @"CODE_128";
    if ([type isEqualToString:AVMetadataObjectTypeUPCECode]) return @"UPC_E";
    if ([type isEqualToString:AVMetadataObjectTypeITF14Code]) return @"ITF";
    return type ?: @"";
}

- (void)closeDueToError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{ if (self.onClose) self.onClose(); }];
}

@end


