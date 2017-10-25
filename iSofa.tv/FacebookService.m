//
//  FacebookService.m
//  youtube video link
//
//  Created by Daniel Popescu on 24/02/14.
//
//

#import "FacebookService.h"

#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "AppDelegate.h"
@interface FacebookService()<FBSDKSharingDelegate>

@end
@implementation FacebookService

+ (id)sharedService {
    static FacebookService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (NSString*)facebookAppId
{
    return @"763554646995203";
    return @"224513627704826";  
}

-(void)clearPermissions
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

-(void)requestReadPermissions
{
    BOOL shouldLogin;
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
      //  NSLog(@"Found a cached session");
        shouldLogin = FALSE;
    }
    else
    {
      //  NSLog(@"Requesting a new session");
        shouldLogin = TRUE;
    }
    
    [FBSession openActiveSessionWithReadPermissions:[self facebookReadPermissions]
                                       allowLoginUI:shouldLogin
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      
                                      // Handler for session state changes
                                      // This method will be called EACH time the session state changes,
                                      // also for intermediate states and NOT just when the session open
                                      [self sessionStateChanged:session state:state error:error];
                                  }];
}

-(void)requestReadPermissionsWithBlock:(FBServiceReadCompletitionBlock)block
{
    isPublishRequest = FALSE;
    self.readBlock = block;
    [self requestReadPermissions];
}

-(void)requestPublishPermissions
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
      //  NSLog(@"Found a cached session");
        [FBSession openActiveSessionWithPublishPermissions:[self facebookWritePermissions]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:NO
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             
                                             // Handler for session state changes
                                             // This method will be called EACH time the session state changes,
                                             // also for intermediate states and NOT just when the session open
                                             [self sessionStateChanged:session state:state error:error];
                                        }];
    }
}

-(void)postWithURL:(NSURL *)URL andTitle:(NSString *)title anDescription:(NSString *) desc andPicture:(NSURL *) picture
{
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = title;
    content.contentDescription = desc;
    content.contentURL = URL;//[NSURL URLWithString:@"https://developers.facebook.com"];

    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc]init];
    shareDialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
    if (![shareDialog canShow]) {
        // fallback presentation when there is no FB app
        shareDialog.mode = FBSDKShareDialogModeFeedBrowser;
    }
    shareDialog.shareContent =  content;
    shareDialog.fromViewController = [delegate topMostController];
    shareDialog.delegate = self;
    [shareDialog show];
}
#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}
// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void) performPublishAction:(void (^)(void)) action
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        if ([[[FBSession activeSession] permissions] indexOfObject:@"publish_actions"] == NSNotFound)
        {
            [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"]
                                                    defaultAudience:FBSessionDefaultAudienceFriends
                                                  completionHandler:^(FBSession *session, NSError *error) {
                                                      action();
                                                  }];
        }
        else
        {
            // Already logged in
            NSLog(@"Already logged in");
            
            action();
        }
        
        
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceOnlyMe
                                              allowLoginUI:YES
                                         completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             [self sessionStateChanged:session state:state error:error];
             
             if (!error && (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended))
                 action();
             
         }];
    }
}

- (NSArray*)facebookWritePermissions {
    return [NSArray arrayWithObjects:@"publish_actions", @"publish_stream", nil];
}

- (NSArray*)facebookReadPermissions {
    return [NSArray arrayWithObjects:@"user_videos",@"user_posts", @"user_actions.video",@"email",@"friends_videos", @"read_stream", @"friends_actions.video", @"friends_likes", nil];
}

-(BOOL)canMakeRequests
{
    if ([FBSession activeSession].isOpen)
        return TRUE;
    
    return FALSE;
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Set the button title as "Log in with Facebook"
    
    // Confirm logout message
    //    [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    // Set the button title as "Log out"
    
    // Welcome message
    //    [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
    
    if (self.readBlock != nil)
    {
        self.readBlock(TRUE, nil);
        self.readBlock = nil;
    }
    
    if (self.publishBlock)
    {
        self.publishBlock(TRUE, nil);
        self.publishBlock = nil;
    }
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}


@end
