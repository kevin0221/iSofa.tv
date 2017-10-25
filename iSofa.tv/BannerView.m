//
//  BannerView.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 12/12/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "BannerView.h"

@implementation BannerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    //adBannerView.frame = CGRectMake(0, self.frame.size.height - 50, self.frame.size.width - 20, 50);
    self.backgroundColor = [UIColor clearColor];
}
-(void)hideScreen
{
    self.frame = CGRectMake(CGRectZero.origin.x ,
                             CGRectGetHeight(self.superview.frame) - CGRectGetHeight(self.frame),
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame)
                            );
    self.onScreen = NO;
    
    
}
-(void)updateVisualPosition:(BOOL)hide animated:(BOOL )animated
{
    
    float duration = 0.5f;
    if (!animated)
        duration = 0.0f;
  
    [UIView animateWithDuration:duration animations:^{
        if (!hide)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                self.frame = CGRectMake(CGRectZero.origin.x,
                                        CGRectGetHeight(self.superview.frame) - CGRectGetHeight(self.frame),
                                        CGRectGetWidth(self.superview.frame) - 240,
                                        CGRectGetHeight(self.frame)
                                        );
                adBannerView.frame = CGRectMake(2, 10, self.bounds.size.width - 10, self.bounds.size.height - 10 );

            }
            else
            {
                self.frame = CGRectMake(CGRectZero.origin.x,
                                        CGRectGetHeight(self.superview.frame) - CGRectGetHeight(self.frame),
                                        CGRectGetWidth(self.frame),
                                        CGRectGetHeight(self.frame)
                                        );
  
            }
            
            NSLog(@"%@",NSStringFromCGRect(self.frame));
        }
        else
        {
            self.frame = CGRectMake(CGRectZero.origin.x ,
                                    CGRectGetHeight(self.superview.frame) ,
                                    CGRectGetWidth(self.frame),
                                    CGRectGetHeight(self.frame)
                                    );
            
            NSLog(@"%@",NSStringFromCGRect(self.frame));
        }
    }];
    self.onScreen = !hide;
}
- (void)purchasedBanner:(BOOL)succesfull
{
    if (succesfull)
    {
        [self removeFromSuperview];
    }
}
-(void)donateBanner
{
    [[RageIAPHelper sharedInstance] setDelegate:self];
    
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            _products = products;
            if(_products.count > 1)
            {
                 SKProduct *product = nil;
                for(SKProduct *prod in _products)
                {
                    if ([prod.productIdentifier isEqualToString:@"com.fimdesemanapictures.youtubevideo.donate02"])
                    {
                        product = prod;
                        break;
                    }
                }
               
                
                NSLog(@"Buying %@...", product.productIdentifier);
                [[RageIAPHelper sharedInstance] buyProduct:product];
            }
        }
        
    }];
   

}



- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{

}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
}
@end
