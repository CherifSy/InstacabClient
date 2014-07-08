//
//  SVMessageService.h
//  Hopper
//
//  Created by Pavel Tisunov on 23/10/13.
//  Copyright (c) 2013 Bright Stripe. All rights reserved.
//

#import "BaseService.h"
#import "ICPing.h"
#import "ICSignUpInfo.h"

extern NSString *const kClientServiceMessageNotification;

typedef void (^ICClientServiceSuccessBlock)(ICPing *message);
typedef void (^ICClientServiceFailureBlock)();

@interface ICClientService : BaseService

-(void)signInEmail:(NSString *)email
          password:(NSString *)password
           success:(ICClientServiceSuccessBlock)success
           failure:(ICClientServiceFailureBlock)failure;

-(void)signOut;

-(void)requestPickupAt:(ICLocation *)location
               success:(ICClientServiceSuccessBlock)success
               failure:(ICClientServiceFailureBlock)failure;

-(void)ping:(CLLocationCoordinate2D)location
    success:(ICClientServiceSuccessBlock)success
    failure:(ICClientServiceFailureBlock)failure;

-(void)cancelInstacabRequest;

-(void)submitRating:(NSUInteger)rating
       withFeedback:(NSString *)feedback
            forTrip: (ICTrip*)trip
            success:(ICClientServiceSuccessBlock)success
            failure:(ICClientServiceFailureBlock)failure;

-(void)requestMobileConfirmation:(ICClientServiceSuccessBlock)success;

-(void)confirmMobileToken:(NSString *)token
                  success:(ICClientServiceSuccessBlock)success
                  failure:(ICClientServiceFailureBlock)failure;

-(void)applyPromo:(NSString *)promotionCode
          success:(ICClientServiceSuccessBlock)success
          failure:(ICClientServiceFailureBlock)failure;

-(void)validatePromo:(NSString *)promotionCode;

-(void)fareEstimate:(ICLocation *)pickupLocation
        destination:(ICLocation *)destination
            success:(ICClientServiceSuccessBlock)success
            failure:(ICClientServiceFailureBlock)failure;

// TODO: Для изменения телефона, имени, фамилии, e-mail
//-(void)updateClientInfo:(NSDictionary *)clientInfo;

// TODO: Для запоминания поиска на сервере и показа частых адресов
//-(void)locationSearchQuery:(NSString*)query
//               searchTypes:(NSArray *)searchTypes
//                  location:(CLLocationCoordinate2D)location
//                   success:(ICClientServiceSuccessBlock)success
//                   failure:(ICClientServiceFailureBlock)failure;

#pragma mark - Signup Flow

-(void)signUp:(ICSignUpInfo *)info
      success:(ICClientServiceSuccessBlock)success
      failure:(ICClientServiceFailureBlock)failure;

-(void)validateEmail:(NSString *)email
            password:(NSString *)password
              mobile:(NSString *)mobile
         withSuccess:(ICClientServiceSuccessBlock)success
             failure:(ICClientServiceFailureBlock)failure;

- (void)createCardSessionSuccess:(ICClientServiceSuccessBlock)success
                         failure:(ICClientServiceFailureBlock)failure;

- (void)disconnectWithoutTryingToReconnect;

@property (nonatomic, readonly) BOOL isOnline;

@end
