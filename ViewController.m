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
    [self AlphaGo];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark - progress
-(void)AlphaGo
{
    NSLog(@"【阿尔法】启动");
    [self checkTicket];
}

-(BOOL)checkTicket
{
    checkStatus = CHECKSTATUS_TICKET;
    [self startReading];
    return YES;
}


-(void)getCheckTicketResult:(NSString*)ticketString
{
    dispatch_sync(dispatch_get_main_queue(),^{
        [self.ticketActivity startAnimating];
    });
    NSString * ticketCliped;
    if([ticketString rangeOfString:@"ticket:"].location != NSNotFound)
    {
        ticketCliped = [ticketString substringWithRange:NSMakeRange(6, ticketString.length)];
    }
    else if([ticketString rangeOfString:@"uid:"].location != NSNotFound)
    {
        ticketCliped = [ticketString substringWithRange:NSMakeRange(4, ticketString.length)];
    } else {
    
    }
  
    [[HtttpEngine sharedInstance] sendCheckTicketRequest:ticketCliped ResultBlock:^(NSDictionary * responseDictionary, BOOL isSucess) {
        NSLog(@"sendCheckTicketRequest OK");
//        dispatch_sync(dispatch_get_main_queue(),^{
            [self.ticketActivity stopAnimating];
            if (isSucess) {
                [self checkBracelet];
            } else {
                
            }
     }];
}

-(BOOL)checkBracelet
{
    checkStatus = CHECKSTATUS_BRACELET;
    [self startReading];
    return YES;
}

-(void)getCheckBraceletResult:(NSString*)braceletString
{
    dispatch_sync(dispatch_get_main_queue(),^{
        [self.braceletActivity startAnimating];
    });
    
    [[HtttpEngine sharedInstance] sendCheckTicketRequest:^(BOOL isSucess) {
        NSLog(@"sendCheckTicketRequest OK");
        dispatch_sync(dispatch_get_main_queue(),^{
            [self.braceletActivity stopAnimating];
            
            if (isSucess) {
//                [self checkBracelet];
                
            } else {
                
            }
            
            
        });
    }];

}

#pragma mark - Qr scan
- (BOOL)startReading {
    NSLog(@"摄像头启动");
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


-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil; _isReading = NO;
//    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (!_isReading) {
        return;
    }
    NSString *stringValue;
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        stringValue = metadataObj.stringValue;
        NSLog(@"扫描出二维码:%@", stringValue);
        switch (checkStatus) {
            case CHECKSTATUS_TICKET:
            {
                NSLog(@"发送检查门票请求");
                [self getCheckTicketResult:stringValue];
            }
                break;
            case CHECKSTATUS_BRACELET:
            {
                  NSLog(@"发送检查手环请求");
                [self getCheckBraceletResult:stringValue];
            }
                break;
            default:
                break;
        }
        
    }
//    [_captureSession stopRunning];
    [self stopReading];
    dispatch_sync(dispatch_get_main_queue(),^{
        switch (checkStatus) {
            case CHECKSTATUS_TICKET:
            {
               self.ticketLabel.text = stringValue;
            }
                break;
            case CHECKSTATUS_BRACELET:
            {
                self.braceletLabel.text = stringValue;
            }
                break;
            default:
                break;
        }

       
    });
}

@end
