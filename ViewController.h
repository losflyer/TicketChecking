//
//  ViewController.h
//  TicketChecking
//
//  Created by Tiger on 14-7-24.
//  Copyright (c) 2014年 Cao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, CHECKSTATUS)
{
    CHECKSTATUS_TICKET = 0,
    CHECKSTATUS_BRACELET,

};
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView * popView;
@property (weak, nonatomic) IBOutlet UIView * captureView;
@property (weak, nonatomic) IBOutlet UILabel * ticketLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * ticketActivity;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * braceletActivity;
@property (weak, nonatomic) IBOutlet UILabel * braceletLabel;
@end
