//
//  HtttpEngine.m
//  TicketChecking
//
//  Created by Tiger on 14-8-1.
//  Copyright (c) 2014年 Cao Liu. All rights reserved.
//

#import "HtttpEngine.h"
#import "AFHTTPRequestOperationManager.h"


#define YHApiPrivateKey @"cd730cc41684571d49e845b21fee256d"

@implementation HtttpEngine




-(void)sendCheckTicketRequest
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters1 = @{@"open_key": @"6f330cf7", @"method": @"Yohood.Entrance.ticket",@"ticket_code": @"ticket:20140724"};
    NSMutableDictionary * parameters =  [[NSMutableDictionary alloc] initWithDictionary:parameters1];
    [self _encodeParams:parameters];
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
