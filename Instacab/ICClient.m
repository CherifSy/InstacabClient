//
//  SVClient.m
//  Hopper
//
//  Created by Pavel Tisunov on 10/22/13.
//  Copyright (c) 2013 Bright Stripe. All rights reserved.
//

#import "ICClient.h"

@interface ICClient ()
@property (nonatomic, copy) NSNumber *uID;
@end

@implementation ICClient

+ (instancetype)sharedInstance {
    static ICClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
        [sharedClient load];
    });
    return sharedClient;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary: @{
        @"token": @"token",
        @"state": @"state",
        @"tripPendingRating": @"tripPendingRating"
    }];
}

+ (NSValueTransformer *)tripPendingRatingJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:ICTrip.class];
}

+ (NSValueTransformer *)stateJSONTransformer {
    NSDictionary *states = @{
        @"Looking": @(SVClientStateLooking),
        @"Dispatching": @(SVClientStateDispatching),
        @"WaitingForPickup": @(SVClientStateWaitingForPickup),
        @"OnTrip": @(SVClientStateOnTrip),
        @"PendingRating": @(SVClientStatePendingRating)
    };
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}

-(void)update: (ICClient *)client {
    if (client)
        [self mergeValuesForKeysFromModel:client];
}

- (void)mergeValueForKey:(NSString *)key fromModel:(MTLModel *)model {
    // don't merge email & password
    if ([key isEqualToString:@"email"] || [key isEqualToString:@"password"]) return;

    // don't merge token if it's nil
    if ([key isEqualToString:@"token"] && [model valueForKey:key] == nil) return;
    
    [super mergeValueForKey:key fromModel:model];
}

-(void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.email = [defaults objectForKey:@"client.email"];
    self.password = [defaults objectForKey:@"client.password"];
    self.token = [defaults objectForKey:@"client.token"];
    self.uID = [defaults objectForKey:@"client.id"];
    
    NSLog(@"Load client %@", self.email);
}

-(void)save {
    NSLog(@"Save client %@", self.email);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.email forKey:@"client.email"];
    [defaults setObject:self.password forKey:@"client.password"];
    [defaults setObject:self.token forKey:@"client.token"];
    [defaults setObject:self.uID forKey:@"client.id"];
    [defaults synchronize];
}

-(void)logout {
    [super clear];
    _token = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"client.token"];
    [defaults removeObjectForKey:@"client.id"];
    [defaults synchronize];
}

-(BOOL)isSignedIn {
    return _token != NULL;
}

@end
