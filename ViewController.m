//
//  ViewController.m
//  TicketChecking
//
//  Created by Tiger on 14-7-24.
//  Copyright (c) 2014年 Cao Liu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HtttpEngine.h"


@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
{
    BOOL _isReading;
    CHECKSTATUS checkStatus;
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
    [self letusGo];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark - progress
-(void)letusGo
{   
    [self checkTicket];
}

-(BOOL)checkTicket
{
    checkStatus = CHECKSTATUS_TICKET;
    [self startReading];
    return YES;
}


-(void)getCheckTicketResult
{
    [[HtttpEngine sharedInstance] sendCheckTicketRequest:^(BOOL  isSucess)resultBlock{
        if (isSucess) {
            
            
        }
        else
        {
        
        }
    
    }];
}

-(BOOL)checkBracelet
{
    checkStatus = CHECKSTATUS_BRACELET;
    return YES;
}

-(void)getCheckBraceletResult
{
    
}

#pragma mark - Qr scan
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
    

    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];

    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.captureView.layer.bounds];
    [self.captureView.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
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
        NSLog(@"QR = %@", stringValue);
        switch (checkStatus) {
            case CHECKSTATUS_TICKET:
            {
                [self getCheckTicketResult];
            }
                break;
            case CHECKSTATUS_BRACELET:
            {
                [self getCheckBraceletResult];
            }
                break;
            default:
                break;
        }
        
    }
// [_captureSession stopRunning];
    dispatch_sync(dispatch_get_main_queue(),^{
        self.qRLabel.text = stringValue;
    });
}

@end
