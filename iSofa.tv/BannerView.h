//
//  BannerView.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 12/12/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
@interface BannerView : UIView <InAppBannerDelegate,ADBannerViewDelegate>
{
      NSArray *_products;
     IBOutlet ADBannerView *adBannerView;
}
- (IBAction) donateBanner;
@property (nonatomic,strong) id   delegate;
- (void) updateVisualPosition:(BOOL) hide animated:(BOOL )animated;
- (void) hideScreen;
@property (nonatomic,assign) BOOL onScreen;
@end
