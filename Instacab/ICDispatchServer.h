//
//  SVDispatchServer.h
//  Hopper
//
//  Created by Pavel Tisunov on 10/22/13.
//  Copyright (c) 2013 Bright Stripe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SRWebSocket.h"
#import "FCOfflineQueue.h"

extern NSString *const kDispatchServerConnectionChangeNotification;

@protocol ICDispatchServerDelegate <NSObject>
- (void)didReceiveMessage:(NSDictionary *)jsonDictionary;
- (void)didConnect;
- (void)didDisconnect;
@end

@interface ICDispatchServer : FCOfflineQueue<SRWebSocketDelegate>
- (void)sendMessage:(NSDictionary *)message withCoordinates:(CLLocationCoordinate2D)coordinates;
- (void)connect;
- (void)disconnect;

@property (nonatomic, readonly) BOOL connected;
@property (nonatomic) BOOL tryReconnectBeforeReportingDisconnect;
@property (nonatomic, copy) NSString *appType;
@property (nonatomic, weak) id <ICDispatchServerDelegate> delegate;

@end
