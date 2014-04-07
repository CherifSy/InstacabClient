//
//  ICSignUpInfo.m
//  Instacab
//
//  Created by Pavel Tisunov on 15/01/14.
//  Copyright (c) 2014 Bright Stripe. All rights reserved.
//

#import "ICSignUpInfo.h"

@implementation NSString (Helper)

- (BOOL)isPresent {
    return self && self.length;
}

@end

@implementation ICSignUpInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"firstName": @"first_name",
        @"lastName": @"last_name",
        @"email": @"email",
        @"mobile": @"mobile",
        @"password": @"password",
        @"cardNumber": [NSNull null],
        @"cardExpirationMonth": [NSNull null],
        @"cardExpirationYear": [NSNull null],
        @"cardCode": [NSNull null],
    };
}

-(BOOL)accountDataPresent {
    return [_password isPresent] || [_email isPresent] || [_mobile isPresent];
}

@end
