//
//  ExtrasView.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/11/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "SaveView.h"
#import "FacebookService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "GSUserSync.h"
#import "User.h"

@implementation SaveView

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


-(IBAction)onClickExit:(id)sender
{
    self.onScreen = YES;
    [self updateVisualPosition:YES animated:YES];
}


- (IBAction) donateOneDollar
{
    // products...
    _products = [_delegate getProducts];
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
    // products...
    _products = [_delegate getProducts];
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

@end
