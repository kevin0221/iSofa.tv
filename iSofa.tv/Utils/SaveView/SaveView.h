//
//  ExtrasView.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/11/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//
#define FACEBOOK_APP_KEY @"763554646995203"

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <UIKit/UIKit.h>
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>


@protocol SaveViewViewDelegate
@optional
- (void) setProducts:(NSArray *)list;
- (NSArray *) getProducts;
@end


@interface SaveView : UIView
{
    NSDate              *tokenExpireDate;
    NSArray             *_products;
    NSNumberFormatter   *_priceFormatter;
    
    IBOutlet UIButton *cast;
}


@property (nonatomic,strong) id   delegate;
@property (nonatomic,assign) BOOL autoCasting;

- (void) updateVisualPosition:(BOOL) hide animated:(BOOL )animated;
- (void) hideScreen;

@property (nonatomic,assign) BOOL onScreen;
@property (nonatomic,strong)  NSString   *accessToken;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *fbAccount;


@end
