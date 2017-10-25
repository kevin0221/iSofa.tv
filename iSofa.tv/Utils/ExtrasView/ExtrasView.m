//
//  ExtrasView.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/11/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "ExtrasView.h"
#import "FacebookService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "GSUserSync.h"
#import "User.h"

@implementation ExtrasView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - state

-(void)awakeFromNib
{
    [super awakeFromNib];
   
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    _products = nil;
    
}
-(void)hideScreen
{
    self.frame = CGRectMake(CGRectZero.origin.x ,
                            CGRectZero.origin.y - CGRectGetHeight(self.frame),
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame)
                            );
    self.onScreen = NO;

    
}
-(void)updateVisualPosition:(BOOL)hide animated:(BOOL )animated
{
    float duration = 0.5f;
    if (!animated) duration = 0.0f;

    // products...
    _products = [_delegate getProducts];
    if(_products == nil)
    {
        [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            _products = products;
            [_delegate setProducts:_products];
            
        }}];
    }

    
    // resize frame...
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(!hide)
        rect.origin.y = -rect.size.height;
    self.frame = rect;
    
    
    // hide or show...
    [UIView animateWithDuration:duration animations:^{
        if (!hide)
        {
            self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            self.onScreen = YES;
        }
        else
        {
            self.frame = CGRectMake(0, -CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            [self performSelector:@selector(hideView) withObject:nil afterDelay:0.3];
        }
    }];
}


-(void)hideView
{
    self.onScreen = NO;
}


- (IBAction) hdPlay:(UIButton *) hdOn
{
    BOOL sel = !hdOn.selected;
    hdOn.selected = sel;
    if ([_delegate respondsToSelector:@selector(toggleHD:)])
    {
        [_delegate toggleHD:sel];
    }
    
    self.onScreen = YES;
    [self updateVisualPosition:YES animated:YES];
}

-(IBAction) castVideo
{
    
    cast.selected = !cast.selected;
    _autoCasting = cast.selected;
    if ([_delegate respondsToSelector:@selector(startCasting)])
    {
        [_delegate startCasting];
    }
}


-(IBAction) selectCastVideo
{
    if ([_delegate respondsToSelector:@selector(selectCasting)])
    {
        [_delegate selectCasting];
    }
}


- (IBAction) donateOneDollar
{
    if(_products.count > 0)
    {
      
        SKProduct *product = nil;
        for(SKProduct *prod in _products)
        {
            if ([prod.productIdentifier isEqualToString:@"com.fimdesemanapictures.youtubevideo.donate01"])
            {
                product = prod;
                break;
            }
        }

        NSLog(@"Buying %@...", product.productIdentifier);
        [[RageIAPHelper sharedInstance] buyProduct:product];
    }
}


- (IBAction) donateTenDollar
{
    if(_products.count > 0)
    {
       
        SKProduct *product = nil;
        for(SKProduct *prod in _products)
        {
            if ([prod.productIdentifier isEqualToString:@"com.fimdesemanapictures.youtubevideo.donate10"])
            {
                product = prod;
                break;
            }
        }

        NSLog(@"Buying %@...", product.productIdentifier);
        [[RageIAPHelper sharedInstance] buyProduct:product];
    }
}

#pragma mark - here
-(void)requestAccessToken
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        [self refreshFacebookTokenStatus];
    }
    else
    {
        [[FacebookService sharedService] requestReadPermissionsWithBlock:^(BOOL succes, NSError *error)
         {
             if (succes)
             {
                 tokenExpireDate = [FBSession activeSession].accessTokenData.expirationDate;
                 _accessToken    = [FBSession activeSession].accessTokenData.accessToken;
                 [[NSUserDefaults standardUserDefaults] setObject:tokenExpireDate forKey:@"token_date"];
                 [[NSUserDefaults standardUserDefaults] setObject:_accessToken forKey:@"token"];
                 User *user = [[GSUserSync sharedInstance] getSavedUser];
                 user.facebook_id = _accessToken;
                 [[GSUserSync sharedInstance] synchroniseUser:user];
                 
                 
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [self performSelectorOnMainThread:@selector(loadFacebook) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 [self performSelectorOnMainThread:@selector(loadError) withObject:nil waitUntilDone:YES];
             }
         }];
    }
}


- (void)refreshFacebookTokenStatus
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]))
    {
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        if (fbAccounts.count == 0)
        {
            [self moveFacebook];
        }
        
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0]))
        {
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error)
             {
                 if (error)
                 {
                     [self performSelectorOnMainThread:@selector(loadError) withObject:nil waitUntilDone:YES];
//                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook login" message:error.debugDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//                     [alert show];
                 }
                 else
                 {
                     switch (renewResult) {
                         case ACAccountCredentialRenewResultRenewed:
                             [self moveFacebook];
                             break;
                             
                         case ACAccountCredentialRenewResultRejected:
                             [self performSelectorOnMainThread:@selector(loadError) withObject:nil waitUntilDone:YES];
                             break;
                             
                         case ACAccountCredentialRenewResultFailed:
                             NSLog(@"non-user-initiated cancel, you may attempt to retry");
                             [self refreshFacebookTokenStatus];
                             break;
                             
                         default:
                             break;
                     }
                 }
             }];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(loadError) withObject:nil waitUntilDone:YES];
        }
    }
    else
    {
        [self performSelectorOnMainThread:@selector(loadError) withObject:nil waitUntilDone:YES];
    }
}


- (void) moveFacebook
{
    self.accountStore = [[ACAccountStore alloc] init];
    
    // Get the Facebook account type for the access request
    ACAccountType *fbAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *_facebookPermissions = @[@"user_videos", @"user_posts",@"user_actions.video", @"email"];
    
    NSDictionary *fbInfo =  [[NSDictionary alloc] initWithObjectsAndKeys:
                             FACEBOOK_APP_KEY,  ACFacebookAppIdKey,
                             _facebookPermissions, ACFacebookPermissionsKey,
                             nil];
    
    // Create & populate the dictionary the dictionary
    
    // Request access to the Facebook account with the access inf
    [self.accountStore requestAccessToAccountsWithType:fbAccountType
                                               options:fbInfo
                                            completion:^(BOOL granted, NSError *error) {
                                                if (error)
                                                {
//                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook login" message:error.debugDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//                                                    [alert show];
                                                    
                                                    [self performSelectorOnMainThread:@selector(loadError) withObject:nil waitUntilDone:YES];
                                                }
                                                if (granted)
                                                {
                                                    // If access granted, then get the Facebook account info
                                                    
                                                    
                                                    NSArray *accounts = [self.accountStore
                                                                         accountsWithAccountType:fbAccountType];
                                                    self.fbAccount = [accounts lastObject];
                                                    
                                                    // Get the access token, could be used in other scenarios
                                                    ACAccountCredential *fbCredential = [self.fbAccount credential];
                                                    NSString *accessToken = [fbCredential oauthToken];
                                                    
                                                    _accessToken    = accessToken;
                                                    [[NSUserDefaults standardUserDefaults] setObject:_accessToken forKey:@"token"];
                                                    User *user = [[GSUserSync sharedInstance] getSavedUser];
                                                    user.facebook_id = _accessToken;
                                                    [[GSUserSync sharedInstance] synchroniseUser:user];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    [self performSelectorOnMainThread:@selector(loadFacebook) withObject:nil waitUntilDone:YES];
                                                    // Add code here to make an API request using the SLRequest class
                                                    
                                                }
                                                else
                                                {
                                                    
                                                }
                                            }];
    
}

- (void) loadError
{
    if([_delegate respondsToSelector:@selector(settingsError)])
    {
        [_delegate settingsError];
    }
}


- (void) loadFacebook
{
    if([_delegate respondsToSelector:@selector(settingsLoadedAccessToken)])
    {
        [_delegate settingsLoadedAccessToken];
    }
}


-(void)loadFacebookToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token_date"])
    {
        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"token_date"];
        
        if ([[NSDate date] compare:date] == NSOrderedDescending)
        {
            [self requestAccessToken];
        }
        else
        {
            tokenExpireDate = date;
            _accessToken    = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
            
            User *user = [[GSUserSync sharedInstance] getSavedUser];
            user.facebook_id = _accessToken;
            [[GSUserSync sharedInstance] synchroniseUser:user];
            
            [self loadFacebook];
        }
    }
    else
    {
        [self requestAccessToken];
    }
}

-(IBAction)onClickExit:(id)sender
{
    self.onScreen = YES;
    [self updateVisualPosition:YES animated:YES];
}

@end
