//
//  PlayMenu.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookService.h"
#import <Foundation/Foundation.h>



@protocol ShareMenuDelegate
-(void)sendEmail:(NSString *)body;
-(void)copyLink;
-(void)clickSave;
-(void)clickThumbler;
-(void)onGoogleSignin;
@end


@class Video;
@interface ShareMenu : UIView<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate> //GPPShareDelegate,GPPSignInDelegate
{
    Video *currentVideo;
}


@property (nonatomic,strong) IBOutlet id   delegate;
@property (nonatomic,assign) BOOL onScreen;

- (IBAction) onClickGoogle:(UIButton *)sender;
- (IBAction) onClickFacebook:(UIButton *)sender;
- (IBAction) onClickTwitter:(UIButton *)sender;
- (IBAction) onClickEmail:(UIButton *)sender;

- (void) setVideo:(Video *) video;
- (void)showGooglePlusShare;

@end
