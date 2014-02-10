//
//  ICDispatchServer.m
//  Instacab
//
//  Created by Pavel Tisunov on 10/22/13.
//  Copyright (c) 2013 Bright Stripe. All rights reserved.
//

#import "ICDispatchServer.h"
#import <AdSupport/ASIdentifierManager.h>
#import <Foundation/NSJSONSerialization.h>
#import <sys/sysctl.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLResponseSerialization.h"
#import "AFURLRequestSerialization.h"
#import "TargetConditionals.h"
#import "UIDevice+FCUtilities.h"

@interface ICDispatchServer ()

@end

@implementation ICDispatchServer {
    NSString *_appVersion;
    NSString *_deviceId;
    NSString *_deviceModel;
    NSString *_deviceOS;
    NSString *_deviceModelHuman;
    int _reconnectAttempts;
    NSString *_jsonPendingSend;
    
    SRWebSocket *_socket;
}

NSUInteger const kMaxReconnectAttemps = 2;
NSString * const kDevice = @"iphone";
NSString * const kDispatchServerConnectionChangeNotification = @"connection:notification";

#if !(TARGET_IPHONE_SIMULATOR)
    // @"http://192.168.1.36.xip.io:9000/"
    NSString * const kDispatchServerUrl = @"http://node.instacab.ru";
    NSString * const kDispatchServerHostName = @"node.instacab.ru";
#else
    NSString * const kDispatchServerUrl = @"http://localhost:9000";
    NSString * const kDispatchServerHostName = @"localhost:9000";
#endif

- (id)init
{
    if ((self = [super initWithReachabilityHostname:kDispatchServerHostName allowCellular:YES launchDelay:2.0]))
    {
        _reconnectAttempts = kMaxReconnectAttemps;
        
        // Initialize often used instance variables
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _deviceId = [ASIdentifierManager.sharedManager.advertisingIdentifier UUIDString];
        _deviceOS = UIDevice.currentDevice.systemVersion;
        _deviceModel = UIDevice.currentDevice.fc_modelIdentifier;
        _deviceModelHuman = UIDevice.currentDevice.fc_modelHumanIdentifier;
    }
    return self;
}

- (NSMutableDictionary *)buildGenericDataWithLatitude: (double) latitude longitude: (double) longitude {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:_deviceOS forKey:@"deviceOS"];
    [data setValue:_deviceModel forKey:@"deviceModel"];
    [data setValue:_deviceModelHuman forKey:@"deviceModelHuman"];
    [data setValue:_appVersion forKey:@"appVersion"];
    [data setValue:_appType forKey:@"app"];
    [data setValue:kDevice forKey:@"device"];
    // Unix epoch time
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    [data setValue:[NSNumber numberWithLong:timestamp] forKey:@"epoch"];
    // Device id
    [data setValue:_deviceId forKey:@"deviceId"];
    // Location
    [data setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [data setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];

    return data;
}

// LATER: Initialize one time only
//- (NSString *)timestampUTC{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    
//    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//    [dateFormatter setTimeZone:gmt];
//    
//    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
//    
//    return timeStamp;
//}

- (BOOL)executeOperation:(int64_t)opcode userInfo:(NSDictionary *)userInfo
{
    return [self _sendData:userInfo];
}

- (void)sendMessage:(NSDictionary *)message withCoordinates:(CLLocationCoordinate2D)coordinates {
    NSMutableDictionary *data =
        [self buildGenericDataWithLatitude:coordinates.latitude
                                 longitude:coordinates.longitude];
    
    [data addEntriesFromDictionary:message];
    
    [self enqueueOfflineOperation:0 userInfo:data];
    
    if (!self.connected) {
        [self connect];
    }
}

- (NSString *)_serializeToJSON: (NSDictionary *)message {
    NSError *error;
    NSData *jsonData =
        [NSJSONSerialization dataWithJSONObject:message
                                        options:NSJSONWritingPrettyPrinted
                                         error:&error];
    NSAssert(jsonData, @"Got an error converting to JSON: %@", error);
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Received: %@", message);
    NSError *error;

    // Convert string to JSON dictionary
    NSDictionary *jsonDictionary =
        [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                        options:NSJSONReadingMutableContainers
                                          error:&error];
    
    NSAssert(jsonDictionary, @"Got an error converting string to JSON dictionary: %@", error);
    
    [self.delegate didReceiveMessage:jsonDictionary];
}

- (BOOL)_sendData:(NSDictionary *)data {
    if (!self.connected) return NO;

    NSLog(@"Sending message %@", data);
    [_socket send:[self _serializeToJSON:data]];
    return YES;
}

-(void)handleDisconnect {
    _socket = nil;
    
    if (_reconnectAttempts == 0 || !self.tryReconnectBeforeReportingDisconnect) {
        [self.delegate didDisconnect];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDispatchServerConnectionChangeNotification object:self];
        _reconnectAttempts = kMaxReconnectAttemps;
        return;
    }
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _reconnectAttempts--;
        NSLog(@"Restoring connection, attemps left %d", _reconnectAttempts);
        [self connect];
    });
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Connected to dispatch server %@", kDispatchServerHostName);
    _reconnectAttempts = kMaxReconnectAttemps;
    
    // Resume message queue
    [self setSuspended:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDispatchServerConnectionChangeNotification object:self];
    
    // we always call this last, to prevent a race condition if the delegate calls 'send' and overrides data
    if ([self.delegate respondsToSelector:@selector(didConnect)]) {
        [self.delegate didConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Dispatch server connection closed with code %ld, reason %@", (long)code, reason);
    
    [self handleDisconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Dispatch server connection failed with %@", error);

    [self handleDisconnect];
}

- (void)connect {
    if (_socket && _socket.readyState == SR_CONNECTING) {
        NSLog(@"Already establishing connection to dispatch server...");
        return;
    }
    
    NSLog(@"Initiating connection to dispatch server");
    
    _socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:kDispatchServerUrl]];
    _socket.delegate = self;
    [_socket open];
}

-(void)disconnect {
    NSLog(@"Close connection to dispatch server");
    
    [_socket closeWithCode:1000 reason:@"Graceful disconnect"];
    _socket = nil;
}

-(BOOL)connected {
    return _socket.readyState == SR_OPEN;
}

@end
