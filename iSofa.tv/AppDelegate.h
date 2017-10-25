//
//  AppDelegate.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GooglePlus/GooglePlus.h>
#import "GAI.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate> //,GPPDeepLinkDelegate>
@property(nonatomic, strong) id<GAITracker> tracker;
@property (strong, nonatomic) UIWindow *window;

extern UIImageView          *backgroundView;
extern NSArray              *arrChannels;
extern NSString             *strSearchChannel;
extern NSString             *strCurrentChannel;


-(UIViewController*) topMostController;
@end

