#import "LluScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LluScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) NSMutableSet<NSString *> *recentValues;
@end

@implementation LluScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self requestCameraIfNeededAndSetup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
}

- (void)dealloc {
    [self.session stopRunning];
}

- (void)requestCameraIfNeededAndSetup {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        [self setupCamera];
        return;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) { [weakSelf setupCamera]; }
                else { [weakSelf closeDueToError:nil]; }
            });
        }];
        return;
    }
    // Denied/Restricted
    [self closeDueToError:nil];
}

- (void)setupCamera {
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input || error) { [self closeDueToError:error]; return; }
    if ([self.session canAddInput:input]) { [self.session addInput:input]; }

    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:self.metadataOutput]) { [self.session addOutput:self.metadataOutput]; }
    dispatch_queue_t queue = dispatch_get_main_queue();
    [self.metadataOutput setMetadataObjectsDelegate:self queue:queue];
    self.metadataOutput.metadataObjectTypes = [self desiredMetadataTypesFromInputType:self.inputType fallback:self.metadataOutput.availableMetadataObjectTypes];

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];

    [self.session startRunning];
}

- (NSArray<AVMetadataObjectType> *)desiredMetadataTypesFromInputType:(NSString *)inputType fallback:(NSArray<AVMetadataObjectType> *)fallback {
    if (![inputType isKindOfClass:[NSString class]] || inputType.length == 0) { return fallback; }
    NSString *lower = [inputType lowercaseString];
    if ([lower isEqualToString:@"qrcode"] || [lower isEqualToString:@"qr"]) {
        return @[AVMetadataObjectTypeQRCode];
    }
    if ([lower isEqualToString:@"barcode"] || [lower isEqualToString:@"ean"] || [lower isEqualToString:@"upc"]) {
        NSMutableArray *types = [NSMutableArray array];
        for (AVMetadataObjectType t in fallback) {
            if ([t isEqualToString:AVMetadataObjectTypeEAN13Code] ||
                [t isEqualToString:AVMetadataObjectTypeEAN8Code] ||
                [t isEqualToString:AVMetadataObjectTypeUPCECode] ||
                [t isEqualToString:AVMetadataObjectTypeCode128Code] ||
                [t isEqualToString:AVMetadataObjectTypeITF14Code]) {
                [types addObject:t];
            }
        }
        return types.count > 0 ? types : fallback;
    }
    return fallback;
}

- (void)metadataOutput:(AVCaptureMetadataOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count == 0) { return; }
    AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)metadataObjects.firstObject;
    if (![obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) { return; }
    NSString *value = obj.stringValue ?: @"";
    NSString *type = obj.type ?: @"";

    if (self.continuous) {
        if (!self.recentValues) { self.recentValues = [NSMutableSet set]; }
        if ([self.recentValues containsObject:value]) {
            return; // deduplicate quick successive reads
        }
        [self.recentValues addObject:value];
        // purge after short delay
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.recentValues removeObject:value];
        });
    }

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


