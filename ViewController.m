//
//  ViewController.m
//  TicketChecking
//
//  Created by Tiger on 14-7-24.
//  Copyright (c) 2014年 Cao Liu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>



@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
{
    BOOL _isReading;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * captureSession;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * videoPreviewLayer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _isReading = NO;
    [self startReading];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)startReading {
    _isReading = YES;
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
//    if (self.qrcodeFlag)
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
//    else
//        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.captureView.layer.bounds];
    [self.captureView.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
     self.qRLabel.text = @"12345";
    return YES;
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
/*

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
}*/

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        stringValue = metadataObj.stringValue;
        NSLog(stringValue);
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Default Alert View" message:stringValue delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//        [alertView show];
        
    }
// [_captureSession stopRunning];
    dispatch_sync(dispatch_get_main_queue(),^{
        self.qRLabel.text = stringValue;
    });
}

@end
