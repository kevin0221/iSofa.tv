//
//  AppDelegate.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "AppDelegate.h"
#import "FacebookService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RageIAPHelper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>

//static NSString * const kClientID = @"273042816169-t0th9esfjvemaukgd60j0nbtd3ip5hmk.apps.googleusercontent.com";
static NSString * const kClientID = @"252723577548-g5ftqnem93qomha272qkvcscinohlasl.apps.googleusercontent.com";

//static NSInteger appRunCount = 0;

/******* Set your tracking ID here *******/

static NSString *const kTrackingId = @"UA-1252205-6";
static NSString *const kAllowTracking = @"allowTracking";


/******* Set CollectionView *******/

UIImageView          *backgroundView;
NSArray              *arrChannels;
NSString             *strSearchChannel = @"";
NSString             *strCurrentChannel = @"";



@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
     [RageIAPHelper sharedInstance];
    
    
    
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    self.tracker = [[GAI sharedInstance] trackerWithName:@"iSofa" trackingId:kTrackingId];
    
    
    [[GAI sharedInstance].defaultTracker setAllowIDFACollection:YES];
    
    /*
    [GPPSignIn sharedInstance].clientID = kClientID;
    // Read Google+ deep-link data.
    [GPPDeepLink setDelegate:self];
    
    [GPPDeepLink readDeepLinkAfterInstall];
    */
    
    return YES;
}

/*
- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink {
    // An example to handle the deep link data.
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deep-link Data"
                          message:[deepLink deepLinkID]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}
 */

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[FBSession activeSession] close];
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString* scheme = [url scheme];
    
    if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", [[FacebookService sharedService] facebookAppId]]])
        return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];//[FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    else
        //if([scheme compare:[[NSBundle mainBundle] bundleIdentifier]] ==  NSOrderedSame)
            return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
            //return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
    
}

-(UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}
@end
