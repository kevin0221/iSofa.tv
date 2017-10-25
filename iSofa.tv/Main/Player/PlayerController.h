//
//  PlayerController.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PlayMenu.h"
#import "TimeMenu.h"
#import "VolumeMenu.h"
#import "InfoView.h"
#import "ExtrasView.h"
#import "ChannelsView.h"
#import <GoogleCast/GoogleCast.h>
#import "BannerView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "RageIAPHelper.h"
#import "AppDelegate.h"
#import "ShareMenu.h"
#import "WatchView.h"
#import "SaveView.h"

#import <GoogleSignIn/GoogleSignIn.h>


@protocol PlayerControllerDelegate
@optional
- (void) playerInitiatedSearch:(NSString *) keyword;
- (void) playerPressedPlaylist;
- (void) playerPressedBack;
- (void) nextStepVideo;

@end


@interface PlayerController : GAITrackedViewController <PlayMenuDelegate, TimeMenuDelegate, UITextFieldDelegate, ShareMenuDelegate, MFMailComposeViewControllerDelegate,
                                                ExtrasViewDelegate,UIAlertViewDelegate,GCKDeviceScannerListener,GCKDeviceManagerDelegate,
                                                GCKMediaControlChannelDelegate,UIActionSheetDelegate, GIDSignInDelegate, GIDSignInUIDelegate>
{
    PlayMenu                        *playMenu;
    TimeMenu                        *timeMenu;
    VolumeMenu                      *volumeMenu;
    InfoView                        *infoView;
    ExtrasView                      *extrasView;
    ChannelsView                    *channelsView;
    BannerView                      *bannerView;
    ShareMenu                       *shareView;
    
    SaveView                        *saveView;
    WatchView                       *watchView;
    
    
    BOOL                            bPinch;
    BOOL                            quality;
    MPMoviePlayerController         *player;
    NSArray                         *products;
    
    NSTimer                         *ratingTimer;
    NSTimer                         *bannerTimer;
}




@property (nonatomic,strong) id   delegate;
@property (nonatomic,strong) Video *video;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) NSInteger index;


@property (weak, nonatomic) IBOutlet UITextField        *txtSearch;
@property (weak, nonatomic) IBOutlet UIView             *searchView;
@property (weak, nonatomic) IBOutlet UIView             *playView;
@property (weak, nonatomic) IBOutlet UIView             *topBannerView;
@property (weak, nonatomic) IBOutlet UIImageView        *thumbnailView;
@property (weak, nonatomic) IBOutlet UIView             *loadingView;
@property (weak, nonatomic) IBOutlet UIView             *buttonView;
@property (weak, nonatomic) IBOutlet UIImageView        *avatarView;
@property (weak, nonatomic) IBOutlet UIView             *infoUIView;
@property (weak, nonatomic) IBOutlet UIView             *shareUIView;
@property (weak, nonatomic) IBOutlet UIView             *bufferingView;


- (void) stopActions;
- (BOOL) checkLogin:(NSString *)name;
- (IBAction)onExitSearch:(id)sender;


@end
