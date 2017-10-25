//
//  InfoView.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 25/11/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GooglePlus/GooglePlus.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookService.h"

@class Video;
@interface InfoView : UIView <UINavigationControllerDelegate>
{
   IBOutlet UIImageView *image;
   IBOutlet UILabel *name;
   IBOutlet UILabel *time;
   IBOutlet UILabel *date;
   IBOutlet UILabel *views;
   IBOutlet UITextView *description;
   IBOutlet UIImageView *profilePicture;
   IBOutlet UIImageView *placeView;
    
   Video *currentVideo;
}


@property (nonatomic,strong) id   delegate;
- (void) updateVideo:(Video *) video;
- (void) updateVisualPosition:(BOOL) hide animated:(BOOL )animated;
- (void) hideScreen;
@property (nonatomic,assign) BOOL onScreen;


@end
