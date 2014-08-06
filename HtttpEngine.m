//
//  HtttpEngine.m
//  TicketChecking
//
//  Created by Tiger on 14-8-1.
//  Copyright (c) 2014年 Cao Liu. All rights reserved.
//

#import "HtttpEngine.h"
#import "AFHTTPRequestOperationManager.h"


@implementation HtttpEngine


+ (HtttpEngine *)sharedInstance
{
    static HtttpEngine *sharedGlobalInstance = nil;
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedGlobalInstance = [[HtttpEngine alloc] init];
    });
    return sharedGlobalInstance;
}


-(void)sendHttpPostRequest:(NSDictionary*)parametersDictionary ResponseBlock:(void (^)(NSDictionary * responseDictionary, BOOL  isSucess))ResponseBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary * finalParameters =  [[NSMutableDictionary alloc] initWithDictionary:parametersDictionary];
    [self _encodeParams:finalParameters];
    
    [manager POST:YH_HOST parameters:finalParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary * dictionary;
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            dictionary =(NSDictionary *)responseObject;
//            NSString* msg = [dictionary objectForKey:@"message"];
            
        }
        ResponseBlock(dictionary, YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
        
        ResponseBlock(error.userInfo, NO);
    }];

}


#pragma mark - 验票
-(void)sendCheckTicketRequest:(NSString *)ticketString ResultBlock:(void (^)(NSDictionary * responseDictionary, BOOL  isSucess))responseBlock
{

    NSDictionary *parameters = @{@"open_key":YH_OPEN_KEY, @"method":YH_CHECK_TICKET, @"ticket_code": ticketString};
    [self sendHttpPostRequest:parameters ResponseBlock:responseBlock];
}

//验UID
//http://api.open.yohobuy.com/?open_key=123456&method=Yohood.Entrance.pass&uid=     验证uid
#pragma mark - 验UID
-(void)sendCheckUIDRequest:(NSString *)uidString ResultBlock:(void (^)(NSDictionary * responseDictionary, BOOL  isSucess))responseBlock
{

    NSDictionary *parameters = @{@"open_key":YH_OPEN_KEY, @"method": YH_CHECK_UID, @"uid": uidString};
    [self sendHttpPostRequest:parameters ResponseBlock:responseBlock];

}


#pragma mark - 绑定

-(void)sendBindingRequest
{
    //这个是绑定的接口
    //门票：ticket:20140723111  ,UID=43  使用日期：2014-07-23
    //http://api.open.yohobuy.com/?open_key=123456&method=Yohood.Entrance.passbinding&uid=用户UID&hand_card=手环CODE
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"open_key": @"6f330cf7", @"method": @"Yohood.Entrance.passbinding",@"uid": @"43", @"hand_card":@"66"};
    
    [manager POST:@"http://api.open.yohobuy.com" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSDictionary * dictionary;
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                dictionary =(NSDictionary *)responseObject;
                NSString* msg = [dictionary objectForKey:@"message"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Default Alert View" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
}




#pragma mark - Utility
- (NSString *)YH_MD5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


- (void) _encodeParams:(NSMutableDictionary *) params {
    [params setObject:YHApiPrivateKey forKey:@"private_key"];
    
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in params.keyEnumerator) {
        [keys addObject:key];
    }
    [keys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *s1 = (NSString *)obj1;
        NSString *s2 = (NSString *)obj2;
        return [s1 compare:s2];
    }];
    
    NSMutableArray *strings = [NSMutableArray array];
    for (NSString *key in keys) {
        NSString *value = [params objectForKey:key];
        value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        [strings addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    NSString *source = [strings componentsJoinedByString:@"&"];
    NSLog(source);    [params setObject:[self YH_MD5:source ] forKey:@"client_secret"];
}

@end
