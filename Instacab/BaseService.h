//
//  BaseService.h
//  InstaCab
//
//  Created by Pavel Tisunov on 07/03/14.
//  Copyright (c) 2014 Bright Stripe. All rights reserved.
//

#import "ICDispatchServer.h"
#import "ICSingleton.h"

@protocol BaseServiceDelegate <NSObject>
- (void)requestDidTimeout;
@end

extern NSString * const kFieldMessageType;
extern NSString * const kFieldEmail;
extern NSString * const kFieldPassword;

@interface BaseService : ICSingleton<ICDispatchServerDelegate>
-(id)initWithAppType:(NSString *)appType keepConnection:(BOOL)keep infiniteResend:(BOOL)infiniteResend;
-(void)sendMessage:(NSDictionary *)message;
-(void)sendMessage:(NSDictionary *)message coordinates:(CLLocationCoordinate2D)coordinates;

-(void)cancelRequestTimeout;

@property (nonatomic, readonly, strong) ICDispatchServer *dispatchServer;
@property (nonatomic, weak) id <BaseServiceDelegate> delegate;
@end
