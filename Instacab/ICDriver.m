//
//  SVDriver.m
//  Hopper
//
//  Created by Pavel Tisunov on 25/10/13.
//  Copyright (c) 2013 Bright Stripe. All rights reserved.
//

#import "ICDriver.h"

//NSString * const kDriverStateChangeNotification = @"kDriverStateChangeNotification";

@implementation ICDriver

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary: @{
        @"state": @"state",
        @"location": @"location",
    }];
}

+ (NSValueTransformer *)locationJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:ICLocation.class];
}

+ (NSValueTransformer *)stateJSONTransformer {
    NSDictionary *states = @{
        @"OffDuty": @(SVDriverStateOffDuty),
        @"Available": @(SVDriverStateAvailable),
        @"Dispatching": @(SVDriverStateDispatching),
        @"Accepted": @(SVDriverStateAccepted),
        @"Arrived": @(SVDriverStateArrived),
        @"DrivingClient": @(SVDriverStateDrivingClient),
        @"PendingRating": @(SVDriverStatePendingRating)
    };
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}

-(void)call {
    NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", self.mobilePhone];
    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
    [[UIApplication sharedApplication] openURL:phoneURL];
}

-(void)setState:(SVDriverState)state {
//    if (_state != state) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kDriverStateChangeNotification object:self userInfo:@{@"state": [NSNumber numberWithInt:state]}];
//    }
    _state = state;
}

@end
