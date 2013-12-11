//
//  AppDelegate.m
//  Hopper
//
//  Created by Pavel Tisunov on 10/9/13.
//  Copyright (c) 2013 Bright Stripe. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "ICLoginViewController.h"
#import "ICDispatchServer.h"
#import "ICLocationService.h"
#import "UIColor+Colours.h"
#import "UIApplication+Alerts.h"
#import "Bugsnag.h"
//#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [Crashlytics startWithAPIKey:@"513638f30675a9a0e0197887a95cd129213cb96a"];
    [Bugsnag startBugsnagWithApiKey:@"07683146286ebf0f4aff27edae5b5043"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self setupServices:application];
    
    ICLoginViewController *vc = [[ICLoginViewController alloc] initWithNibName:@"ICLoginViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
    nav.navigationBar.barTintColor = [UIColor colorFromHexString:@"#F8F8F4"];
    
    NSDictionary *textAttributes = @{ NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#403F3C"] };
    nav.navigationBar.titleTextAttributes = textAttributes;
    
    [self.window makeKeyAndVisible];
    return YES;
}

// TODO: Что делать когда сети нету и невозможно достучаться до сервера
// http://stackoverflow.com/questions/1290260/reachability-best-practice-before-showing-webview
// TODO: Если соединение с сервером теряется или доступ в сеть пропадает, то сделать еще 3 попытки установить соединение с интервалом в 1 секунду и если не удалось то показать ошибку пользователю и выйти на LoginView
// Из LoginView пользователь будет пробовать еще раз ввести пароль и пытаться войти и если интернета нету то не сможет войти, если есть то войдет и снова продолжит работу с прерванного места.

// Еще мудрые советы от Apple Engineer http://stackoverflow.com/questions/12490578/should-i-listen-for-reachability-updates-in-each-uiviewcontroller

// Как узнать тип соединения, WiFi, 3G or EDGE или Нету Соединения с помощью класса Reachability
// http://stackoverflow.com/questions/11049660/detect-carrier-connection-type-3g-edge-gprs - 2ой ответ

- (void)setupServices:(UIApplication *)application {
    // Google Maps key
    [GMSServices provideAPIKey:@"AIzaSyDcikveiQmWRQ8Qv-gPofHuMHgYhjCpsqQ"];
    
    // Initiate connection to server
    ICDispatchServer *dispatchServer = [ICDispatchServer sharedInstance];
    dispatchServer.appType = @"client";
    
    
    if([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted )
        {
            [application showAlertWithTitle:@"Warning" message:@"Determining your current location cannot be performed at this time because location services are enabled but restricted"];
            
            NSLog(@"Determining your current location cannot be performed at this time because location services are enabled but restricted");
        }
        else {
            // Start updating location
            [[ICLocationService sharedInstance] start];
        }
    }
    else {
        [application showAlertWithTitle:@"Error" message:@"Determining your current location cannot be performed at this time because location services are not enabled."];
        
        NSLog(@"Location services are OFF!");
    }
}

- (void)setupBugTracking {
// Developed by the same developer, these two frameworks offer ability to stand up your own ad-hoc beta app distribution service and incorporate live crash reporting. This situation would be akin to having your own internal TestFlightApp portal and framework available. These frameworks are used by the Flipboard app. The PLCrashReporter framework is at the heart of QuincyKit.
//    https://github.com/TheRealKerni/QuincyKit
//    http://code.google.com/p/plcrashreporter/
    
//  Beta distribution
//    https://github.com/TheRealKerni/HockeyKit
}

- (void)setupLogging {
// CocoaLumberJack which makes it snappy to put log statements in your code, direct the output to multiple loggers, leave in the code without worrying about #ifdef statements to prevent it seeping through into the production code. This framework is used by both Spotify and Facebook apps.
//    https://github.com/robbiehanson/CocoaLumberjack
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
