//
//  HtttpEngine.h
//  TicketChecking
//
//  Created by Tiger on 14-8-1.
//  Copyright (c) 2014年 Cao Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HtttpEngine : NSObject

+ (HtttpEngine *)sharedInstance;

-(void)sendCheckTicketRequest:(NSString *)ticketString ResultBlock:(void (^)(NSDictionary * responseDictionary, BOOL  isSucess))responseBlock;
@end
