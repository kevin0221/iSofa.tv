//
//  PlayerController.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "PlayerController.h"
#import "User.h"
#import "GSUserSync.h"
#import "SMServerAPI.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"
#import "CustomSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@import GoogleMobileAds;


#define BANNER_COUNT            50
#define RATE_COUNT              100
#define RATE_ID                 @"668579899"
#define kClientId @"252723577548-g5ftqnem93qomha272qkvcscinohlasl.apps.googleusercontent.com"


static NSString * kReceiverAppID = @"A8D112E8";;
@interface PlayerController ()
{
    IBOutlet UIView *containerView;
    
    IBOutlet UILabel *avatarName;
    IBOutlet UIImageView *avatarImage;
    
    __weak IBOutlet NSLayoutConstraint *topbannerviewHeight;
    __weak IBOutlet NSLayoutConstraint *topbannerViewWidth;
    IBOutlet UILabel *videoName;
    IBOutlet UILabel *videoTime;
    IBOutlet CustomSlider *videoSlider;
    __weak IBOutlet GADBannerView *adMobbannerView;
    
    NSTimer *timer;
    IBOutlet UIView   *volumeView;
    IBOutlet UISlider *volumeSlider;
    IBOutlet UIView   *menuView;
    IBOutlet UIButton *btnAvatar;
    
    CGSize originalVolumeSize;
    int  bVerticalVolumeSlider;
    
    UIPanGestureRecognizer *swipeGesture;
    
}
@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;
@property GCKDevice *selectedDevice;
@property(nonatomic, strong) GCKDeviceScanner *deviceScanner;
@property(nonatomic, strong) UIButton *chromecastButton;
@property(nonatomic, strong) GCKDeviceManager *deviceManager;
@property(nonatomic, readonly) GCKMediaInformation *mediaInformation;
- (IBAction)onBackward:(id)sender;
- (IBAction)onPlayPause:(id)sender;
- (IBAction)onForward:(id)sender;
- (IBAction)onID1:(id)sender;
@end

@implementation PlayerController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    adMobbannerView.adUnitID = @"ca-app-pub-5224638778814835/2099102707";
    adMobbannerView.rootViewController = self;
    [adMobbannerView loadRequest:[GADRequest request]];
    
    NSLog(@"playView.frame = %@", NSStringFromCGRect(self.playView.frame));
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    // hide volume hud
    CGRect volumeViewRect = CGRectMake(-50, -50, 0, 0);
    MPVolumeView *sysvolumeView = [[MPVolumeView alloc] initWithFrame: volumeViewRect];
    [self.view addSubview: sysvolumeView];
    
    
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    self.screenName = @"Player";
    
    [self dispatchWithCategory:@"Player" andActionName:@"" andLabel:@""];
    [self addNecessaryMenusAndSettings];
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"] == true)
        avatarImage.layer.cornerRadius = 28;
    else
        avatarImage.layer.cornerRadius = 19;
    
  //[videoSlider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    self.deviceScanner = [[GCKDeviceScanner alloc] init];
    
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
    
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"] == true)
        [videoSlider setThumbImage:[UIImage imageNamed:@"thumb_image_ipad"] forState:UIControlStateNormal];
    else
        [videoSlider setThumbImage:[UIImage imageNamed:@"thumb_image"] forState:UIControlStateNormal];
    [videoSlider setMaximumTrackImage:[self maxTrackImage:[UIColor colorWithWhite:1.0f alpha:0]] forState:UIControlStateNormal];
    [videoSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"] == true)
        [volumeSlider setThumbImage:[UIImage imageNamed:@"isofa_player_volume_ipad"] forState:UIControlStateNormal];
    else
        [volumeSlider setThumbImage:[UIImage imageNamed:@"isofa_player_volume"] forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:[self maxTrackImage:[UIColor colorWithWhite:1.0f alpha:0]] forState:UIControlStateNormal];
    [volumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [containerView addGestureRecognizer:tap];

    UITapGestureRecognizer *tapMenu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    [menuView addGestureRecognizer:tapMenu];
    
    UITapGestureRecognizer *tapSearch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preventSearchClose:)];
    [_searchView addGestureRecognizer:tapSearch];
    
    // avatar
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickURL:)];
    avatarImage.userInteractionEnabled = YES;
    [avatarImage addGestureRecognizer:singleTap];
    
    
    // set pinch
    bPinch = false;
    strSearchChannel = @"";
    [self.view bringSubviewToFront: self.searchView];
    
    _shareUIView.hidden = YES;
    
    ratingTimer = NULL;
    bannerTimer = NULL;
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession addObserver:self
                   forKeyPath:@"outputVolume"
                      options:0
                      context:nil];
    
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqual:@"outputVolume"]) {
        float volumeLevel = [[MPMusicPlayerController applicationMusicPlayer] volume] * 10;
        NSLog(@"volume changed! %f",volumeLevel);
        [volumeSlider setValue:volumeLevel];
    }
}


- (void)viewDidUnload
{
//    if (ratingTimer) {
//        [ratingTimer invalidate];
//        ratingTimer = NULL;
//    }
    
//    if (bannerTimer) {
//        [bannerTimer invalidate];
//        bannerTimer = NULL;
//    }
}


- (IBAction)sliderValueChanged:(UISlider *)sender
{
    // change value
    if(sender.tag == 101)
    {
        // volume slider
        [[MPMusicPlayerController applicationMusicPlayer] setVolume: sender.value * 0.1];
    }
    else
    {
        // video slider
        [self timeMenuUpdateWithCurrentValue:sender.value];
    }
}

-(void)viewDidLayoutSubviews
{
    // textfield for search...
    UIColor *color = [UIColor colorWithRed:254/255.0 green:193/255.0 blue:11/255.0 alpha:1];
    [self.txtSearch setValue:color forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtSearch setTextAlignment:NSTextAlignmentLeft];
    
    // loading view....
    self.loadingView.layer.cornerRadius = 10.0f;
    self.loadingView.layer.masksToBounds = YES;
    
    // buttonView frame
    // CGRect rect = self.buttonView.frame;
    // rect.origin.x = self.avatarView.frame.origin.x - rect.size.width/4;
    // self.buttonView.frame = rect;
    NSLog(@"buttonView.frame = %@", NSStringFromCGRect(self.buttonView.frame));
    
    [self adjustVideoNameLabels];
}

-(void)adjustVideoNameLabels
{
    UIFont* videoNameFont = nil;
    UIFont* avatarNameFont = nil;
    
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"] == true) {
        videoNameFont = [UIFont systemFontOfSize:19.0f];
        avatarNameFont = [UIFont systemFontOfSize:16.0f];
    } else {
        videoNameFont = [UIFont systemFontOfSize:16.0f];
        avatarNameFont = [UIFont systemFontOfSize:14.0f];
    }
    
    [videoName setFont:videoNameFont];
    [avatarName setFont:avatarNameFont];
    
    NSLog(@"self.view.frame.size.width = %f", self.view.bounds.size.width);
    CGRect videoNameNewRect = [_video.name
                        boundingRectWithSize:CGSizeMake(self.view.frame.size.width, videoName.frame.size.height)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : videoNameFont
                                     }
                        context:nil];

    CGRect avatarNewRect = [avatarName.text
                               boundingRectWithSize:CGSizeMake(self.view.frame.size.width, avatarName.frame.size.height)
                               options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{
                                            NSFontAttributeName : avatarNameFont
                                            }
                               context:nil];
    
    NSLog(@"Original VideoName Rect = %@, new size = %@", NSStringFromCGRect(videoName.frame), NSStringFromCGRect(videoNameNewRect));
    NSLog(@"Original VideoTime Rect = %@", NSStringFromCGRect(videoTime.frame));
    NSLog(@"Original Avatar    Rect = %@, new Rect = %@", NSStringFromCGRect(avatarName.frame), NSStringFromCGRect(avatarNewRect));
    
    int leftMargin = videoName.frame.origin.x;
    int rightMargin = self.view.frame.size.width - avatarImage.frame.origin.x + 10;
    int spaceWidth = self.view.frame.size.width - leftMargin - rightMargin;
    
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"] == true)
        avatarImage.layer.cornerRadius = 28;
    else
        avatarName.layer.cornerRadius = 19;

    int minSpaceWidth = 20;
    int maxVideoNameWidth = videoNameNewRect.size.width + 20;
    if (maxVideoNameWidth + videoTime.frame.size.width + avatarNewRect.size.width + minSpaceWidth * 2 > spaceWidth)
        maxVideoNameWidth = spaceWidth - videoTime.frame.size.width - avatarNewRect.size.width - minSpaceWidth * 2;
    else {
        minSpaceWidth = (spaceWidth - maxVideoNameWidth - videoTime.frame.size.width - avatarNewRect.size.width) / 2;
    }
    [videoName setFrame:CGRectMake(videoName.frame.origin.x,
                                   (videoName.superview.frame.size.height - videoName.frame.size.height)/2/* videoName.frame.origin.y */,
                                  maxVideoNameWidth, videoName.frame.size.height)];
    [videoTime setFrame:CGRectMake(videoName.frame.origin.x + maxVideoNameWidth + minSpaceWidth,
                                   (videoTime.superview.frame.size.height - videoTime.frame.size.height)/2 /* videoTime.frame.origin.y */,
                                   videoTime.frame.size.width, videoTime.frame.size.height)];
    [avatarName setFrame:CGRectMake(videoTime.frame.origin.x + videoTime.frame.size.width + minSpaceWidth,
                                    (avatarName.superview.frame.size.height - avatarName.frame.size.height)/2  /* avatarName.frame.origin.y */,
                                    avatarNewRect.size.width, avatarName.frame.size.height)];

}

-(void)viewDidAppear:(BOOL)animated
{
    if (bVerticalVolumeSlider == 1)
        return;
    
    // set volume slider
    originalVolumeSize = volumeView.frame.size;
    bVerticalVolumeSlider = 1;
    [self adjustVolumeSlider];
}

-(void)preventSearchClose:(UITapGestureRecognizer *)tapRecognizer
{
    return;
}

-(void)tapScreen:(UITapGestureRecognizer *)tapRecognizer
{
    // tap screen
    self.loadingView.hidden = YES;
    if(menuView.hidden == YES)
    {
        if(!shareView.hidden)
            [self closeShare];
        else
        {
            CGPoint touchPoint = [tapRecognizer locationInView: containerView];
            [self openMenu: touchPoint];
        }
    }
    else
    {
        [self closeMenu];
    }
}

// --------------------------------------------------------------------------------
// Open, close methods....
// --------------------------------------------------------------------------------

-(void) openMenu:(CGPoint)touchPos
{
    // set position
    NSLog(@"playView.frame = %@", NSStringFromCGRect(self.playView.frame));
    touchPos.x -= self.playView.frame.size.width/2;
    touchPos.y -= self.playView.frame.size.height/2;
    
    CGRect rect = self.playView.frame;
    rect.origin.x = touchPos.x;
    if(rect.origin.x < self.playView.frame.size.width/4)
       rect.origin.x = self.playView.frame.size.width/4;
    else if(rect.origin.x > self.view.frame.size.width - self.playView.frame.size.width * 5/4)
        rect.origin.x = self.view.frame.size.width - self.playView.frame.size.width*5/4;
    
    rect.origin.y = touchPos.y;
    if(rect.origin.y < self.playView.frame.size.height/4)
        rect.origin.y = self.playView.frame.size.height/4;
    else if(rect.origin.y > self.view.frame.size.height - self.playView.frame.size.height * 6/4)
        rect.origin.y = self.view.frame.size.height - self.playView.frame.size.height*6/4;
    self.playView.frame = rect;
    NSLog(@"playView.frame = %@", NSStringFromCGRect(self.playView.frame));
    

    // set alpha view
    menuView.alpha  = 0;
    menuView.hidden = NO;
    self.playView.hidden = NO;
    self.loadingView.hidden = YES;
    
    [UIView animateWithDuration:0.5f animations:^{
        menuView.alpha = 1.0f;
    }];
}

-(void) closeMenu
{
    // close menu
    [UIView animateWithDuration:0.5f animations:^{
        menuView.alpha = 0.0f;
        shareView.hidden = YES;
    }];

    self.loadingView.hidden = YES;
    [self performSelector:@selector(hideMenu) withObject:nil afterDelay:0.5f];
}

-(void) hideMenu
{
    menuView.hidden = YES;
}

-(void)openShare
{
    if(shareView.hidden == NO) return;
    
    CGRect rect = shareView.frame;
    rect.origin.x = self.playView.frame.origin.x;
    rect.origin.y = self.playView.frame.origin.y;
    shareView.frame = rect;
    NSLog(@"shareView.frame = %@", NSStringFromCGRect(shareView.frame));
    
    [UIView animateWithDuration:0.5f animations:^{
        shareView.hidden = NO;
        self.playView.hidden = YES;
    }];
}

-(void)closeShare
{
    [UIImageView animateWithDuration:0.5f animations:^{
        shareView.hidden = YES;
    }];
}


-(void) adjustVolumeSlider
{
    CGSize volumeSize = originalVolumeSize;

    volumeSlider.frame = CGRectMake(0, 0, volumeSize.height - 10, volumeSize.width);
    volumeSlider.center   = CGPointMake(volumeView.frame.size.width / 2, volumeView.frame.size.height / 2 );
    volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    volumeView.hidden = NO;
    NSLog(@"volumeSlider.frame = %@", NSStringFromCGRect(volumeSlider.frame));

    [[MPMusicPlayerController applicationMusicPlayer] setVolume: volumeSlider.value * 0.1];
}


-(UIImage *) maxTrackImage:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

 -(void) startTimer
{
    [self stopTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countSeconds) userInfo:nil repeats:YES];
    
}
-(void) stopTimer
{
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
}
-(void) countSeconds
{
    long duration = (long) player.duration;
    int currentHours   = (int)(duration / 3600);
    int currentMinutes = (int)((duration / 60) - currentHours*60);
    int currentSeconds = (int)(duration % 60);
    
    long duration1 = (long) player.currentPlaybackTime;
    int currentHours1  = (int)(duration1 / 3600);
    int currentMinutes1 = (int)((duration1 / 60) - currentHours1*60);
    int currentSeconds1 = (int)(duration1 % 60);
    
    if (currentHours > 0)
    {
        videoTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d / %02d:%02d:%02d",currentHours1,currentMinutes1,currentSeconds1,currentHours,currentMinutes, currentSeconds];
    }
    else
    {
        videoTime.text = [NSString stringWithFormat:@"00:%02d:%02d / 00:%02d:%02d",currentMinutes1,currentSeconds1,currentMinutes, currentSeconds];
    }
    
    videoSlider.value = player.currentPlaybackTime;
}

-(void) purchasedProducts
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.fimdesemanapictures.youtubevideo.donate02"] == YES)
    {
        self.topBannerView.hidden = true;
        [self.topBannerView removeFromSuperview];
    }
}
-(void)chooseDevice:(id)sender {
    //Choose device
    if (self.selectedDevice == nil) {
        //Choose device
        UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Connect to Device", nil)
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        for (GCKDevice *device in self.deviceScanner.devices) {
            [sheet addButtonWithTitle:device.friendlyName];
        }
        
        [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        
        //show device selection
        [sheet showInView:self.view];
    } else {
        // Gather stats from device.
        [self updateStatsFromDevice];
        
        NSString *friendlyName = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil),
                                  self.selectedDevice.friendlyName];
        NSString *mediaTitle = [self.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
        
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.title = friendlyName;
        sheet.delegate = self;
        if (mediaTitle != nil) {
            [sheet addButtonWithTitle:mediaTitle];
        }
        
        //Offer disconnect option
        [sheet addButtonWithTitle:@"Disconnect"];
        [sheet addButtonWithTitle:@"Cancel"];
        sheet.destructiveButtonIndex = (mediaTitle != nil ? 1 : 0);
        sheet.cancelButtonIndex = (mediaTitle != nil ? 2 : 1);
        
        [sheet showInView:self.view];
    }
}

-(void)updateStatsFromDevice {
    
    if (self.mediaControlChannel && self.isConnected) {
        _mediaInformation = self.mediaControlChannel.mediaStatus.mediaInformation;
    }
}

-(IBAction) goBack
{
    [self backPlayerlist];
}

-(void)backPlayerlist
{
    [player stop];
    player = nil;
    
    // back to player list
    if ([_delegate respondsToSelector:@selector(playerPressedBack)])
    {
        [_delegate playerPressedBack];
    }
    
    [self closeShare];
    [self closeMenu];
    
    // take screenshot
    [self takeScreenShot];
    strSearchChannel = @"";
    
    // dismiss
    [self stopActions];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(BOOL)isConnected {
    return self.deviceManager.isConnected;
}

-(void)connectToDevice {
    
    if (self.selectedDevice == nil) return;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    self.deviceManager =
    [[GCKDeviceManager alloc] initWithDevice:self.selectedDevice
                           clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    self.deviceManager.delegate = self;
    [self.deviceManager connect];
    
}

-(void)deviceDisconnected {
    self.mediaControlChannel = nil;
    self.deviceManager = nil;
    self.selectedDevice = nil;
}


//Cast video
-(void)selectCasting
{
    [self dispatchWithCategory:@"Player" andActionName:@"Chromecast" andLabel:@"Select device"];
    [self chooseDevice:nil];
}

-(void)startCasting
{
    [self dispatchWithCategory:@"Player" andActionName:@"Chromecast" andLabel:@"Start device"];
    [self castVideo:nil];
}

-(IBAction)castVideo:(id)sender {
    //NSLog(@"Cast Video");
    
    //Show alert if not connected
    if (!self.deviceManager || !self.deviceManager.isConnected) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not Connected", nil)
                                   message:NSLocalizedString(@"Please connect to Cast device", nil)
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //Define Media metadata
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    [metadata setString:_video.name
                 forKey:kGCKMetadataKeyTitle];
    
    [metadata setString:_video.descriptions
                 forKey:kGCKMetadataKeySubtitle];
    
    [metadata addImage:[[GCKImage alloc]
                        initWithURL:[[NSURL alloc] initWithString:_video.ThumbnailMediumURL]
                        width:480
                        height:360]];
    
    //define Media information
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     _video.playURLHD.relativeString
                                        streamType:GCKMediaStreamTypeBuffered
                                       contentType:@"video/mp4"
                                          metadata:metadata
                                    streamDuration:_video.duration
                                        customData:nil];
    
    //cast video
    [_mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
    
}

#pragma mark - GCKDeviceScannerListener
-(void)deviceDidComeOnline:(GCKDevice *)device {
    //NSLog(@"device found!! %@", device.friendlyName);
  
}

-(void)deviceDidGoOffline:(GCKDevice *)device {
   
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.selectedDevice == nil) {
        if (buttonIndex < self.deviceScanner.devices.count) {
            self.selectedDevice = self.deviceScanner.devices[buttonIndex];
            //NSLog(@"Selecting device:%@", self.selectedDevice.friendlyName);
            [self connectToDevice];
        }
    } else {
        if (buttonIndex == 1) {  //Disconnect button
            //NSLog(@"Disconnecting device:%@", self.selectedDevice.friendlyName);
            // New way of doing things: We're not going to stop the applicaton. We're just going
            // to leave it.
            [self.deviceManager leaveApplication];
            // If you want to force application to stop, uncomment below
            //[self.deviceManager stopApplicationWithSessionID:self.applicationMetadata.sessionID];
            [self.deviceManager disconnect];
            
            [self deviceDisconnected];
           
        } else if (buttonIndex == 0) {
            // Join the existing session.
            
        }
    }
}

#pragma mark - GCKDeviceManagerDelegate

-(void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    //NSLog(@"connected!!");
    
   
    [self.deviceManager launchApplication:kReceiverAppID];
}

-(void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
    
    //NSLog(@"application has launched");
    self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    self.mediaControlChannel.delegate = self;
    [self.deviceManager addChannel:self.mediaControlChannel];
    [self.mediaControlChannel requestStatus];
    
}

-(void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectToApplicationWithError:(NSError *)error {
    [self showError:error];
    
    [self deviceDisconnected];
    
}

-(void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectWithError:(GCKError *)error {
    [self showError:error];
    
    [self deviceDisconnected];
    
}

-(void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
    //NSLog(@"Received notification that device disconnected");
    
    if (error != nil) {
        [self showError:error];
    }
    
    [self deviceDisconnected];
  
    
}

-(void)deviceManager:(GCKDeviceManager *)deviceManager
didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
    self.applicationMetadata = applicationMetadata;
}

#pragma mark - misc
-(void)showError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedString(error.description, nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void) addNecessaryMenusAndSettings
{
//    [self addTimeMenu];
    [self addPlayMenu];
//    [self addVolumeMenu];
    [self addVideoPlayer];
    [self addTapHandler];
    [self addViews];
    
    [self addBannerMenu];
}

-(void) stopActions
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    
    [self stopTimer];
    [player stop];
    
}



// screen capture...
-(void)twoFingerPinch:(UIPinchGestureRecognizer *)pinch
{
    if(!bPinch) //  && menuView.hidden
    {
        bPinch = true;
        [self backPlayerlist];
    }
}

-(void)takeScreenShot
{
    NSInteger interval = player.currentPlaybackTime;
    if(interval <= 0) return;
    
    if(player.playbackState == MPMoviePlaybackStatePlaying)
    {
        UIImage *thumbnail = [player thumbnailImageAtTime:player.currentPlaybackTime timeOption:MPMovieTimeOptionNearestKeyFrame];
        backgroundView.image = thumbnail;
    }
}

-(void) addViews
{
    // channel view
    channelsView  =  (ChannelsView *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:5];
    channelsView.delegate = self.delegate;
    
    [self.view addSubview:channelsView];
    [channelsView updateVisualPosition:YES animated:NO];
    
    
    // share view
    shareView = (ShareMenu*) _shareUIView;
    // shareView  =  (ShareMenu *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:7];
    // shareView.frame = CGRectMake((self.view.frame.size.width - shareView.frame.size.width)/2, (self.view.frame.size.height - shareView.frame.size.height)/2,
    //                             shareView.frame.size.width, shareView.frame.size.height);
    shareView.delegate = self;
    shareView.hidden = YES;
    // NSLog(@"shareView.frame = %@", NSStringFromCGRect(shareView.frame));
    // [self.view addSubview:shareView];
    
    
    // info view...
    infoView = (InfoView*) _infoUIView;
//    infoView  =  (InfoView *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:3];
//    infoView.delegate = self;
//    infoView.alpha = 0.7;
//    
//    [self.view addSubview:infoView];
//    [infoView updateVisualPosition:YES animated:NO];


    // extra view
    extrasView  =  (ExtrasView *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:4];
    extrasView.delegate = self;
    extrasView.alpha = 0.7;
    [self.view addSubview:extrasView];
    [extrasView updateVisualPosition:YES animated:NO];
    
    
    // save view
    saveView  =  (SaveView *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:8];
    saveView.delegate = self;
    saveView.alpha = 0.7;
    [self.view addSubview:saveView];
    [saveView updateVisualPosition:YES animated:NO];
    
    
    // watch view
    watchView  =  (WatchView *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:9];
    watchView.delegate = self;
    watchView.alpha = 0.7;
    [self.view addSubview:watchView];
    [watchView updateVisualPosition:YES animated:NO];
}


-(void) addTimeMenu
{
    timeMenu  =  (TimeMenu *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:1];
    timeMenu.delegate = self;
    
    
    [self.view addSubview:timeMenu];
    [timeMenu showThis];
    [timeMenu updateVisualPosition:YES animated:NO];
}


-(BOOL) shouldAddBanner
{
   /* if ([[RageIAPHelper sharedInstance] productPurchased:@"com.fimdesemanapictures.youtubevideo.donate02"])
    {
        self.topBannerView.hidden = true;
        return NO;
    }else{
        self.topBannerView.hidden = false;
        return YES;

    }*/
    //return true;
    NSInteger count = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger value  = [defaults integerForKey:@"banner_count"];
    count = value + 1;//(int)(value.integerValue + 1);

    [defaults setInteger:count forKey:@"banner_count"];
    [defaults synchronize];
    
    if ([[RageIAPHelper sharedInstance] productPurchased:@"com.fimdesemanapictures.youtubevideo.donate02"])
    {
        self.topBannerView.hidden = YES;
        return NO;
    }
    
    if (count > BANNER_COUNT)
    {
        [self showBanner];
        return YES;
    }
    
    self.topBannerView.hidden = YES;
    return NO;
}

- (IBAction)onBannerClose:(id)sender {
    if (bannerView != NULL) {
        [bannerView updateVisualPosition:NO animated:NO];
    }
}

- (void)purchasedBanner:(BOOL)succesfull
{
    if (succesfull)
    {
        self.topBannerView.hidden = true;
        //[self.topBannerView removeFromSuperview];
    }
}
-(IBAction)donateBanner
{
    [[RageIAPHelper sharedInstance] setDelegate:self];
    
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products1) {
        if (success)
        {
            if(products1.count > 1)
            {
                SKProduct *product = nil;
                for(SKProduct *prod in products1)
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

-(void) addBannerMenu
{
    if([self shouldAddBanner])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchasedProducts) name:IAPHelperProductPurchasedNotification object:nil];
        
        NSLog(@"%@",[[UIDevice currentDevice] model]);
        //if ([[[UIDevice currentDevice] model] containsString:@"iPad"] == true)
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
           // bannerView  =  (BannerView *) [[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:10];


        }else{
            //bannerView  =  (BannerView *) [[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:10];
            topbannerviewHeight.constant = 66;
            topbannerViewWidth.constant = 480;


        }
        
    }
    
    
    // save count...
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value          = [defaults objectForKey:@"banner_count"];
    int count = (int)(value.integerValue - 1);
    [defaults setObject:[NSString stringWithFormat:@"%d",count] forKey:@"banner_count"];*/
}

// show banner view
-(void)showBanner
{
    self.topBannerView.hidden = NO;
}



// show rate
- (void)showRate
{
//    ratingTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f
//                                     target:self
//                                   selector:@selector(targetMethod:)
//                                   userInfo:nil
//                                    repeats:NO];
}

- (void)targetMethod:(NSTimer*)timer
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Help us grow" message:@"Please, rate iSofa.\n\n⭐️⭐️⭐️⭐️⭐️" delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Rate",nil];
    [alert show];
    alert.tag = 101;
    
    [ratingTimer invalidate];
    ratingTimer = NULL;
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 101)
    {
        if(buttonIndex == 1)
        {
            NSURL *url = [NSURL URLWithString:[self getRateURL]];
            if (![[UIApplication sharedApplication] openURL:url])
                NSLog(@"%@%@",@"Failed to open url:",[url description]);
            else
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:YES forKey:@"isRated"];
            }
        }
        else
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:@"isRated"];
            
            ratingTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                                           target:self
                                                         selector:@selector(targetMethod:)
                                                         userInfo:nil
                                                          repeats:NO];
        }
    }
}

-(NSString *)getRateURL
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        return [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", RATE_ID];
    else
        return [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", RATE_ID];
}


-(void) addPlayMenu
{
    playMenu = (PlayMenu*) self.playView;
    playMenu.delegate = self;
    
//    playMenu = (PlayMenu *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] firstObject];
//    playMenu.delegate = self;
//
//    [self.view addSubview:playMenu];
//    [playMenu updateVisualPosition:YES animated:NO];
}
-(void) addVolumeMenu
{
    volumeMenu = (VolumeMenu *)[[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:2];
    volumeMenu.delegate = self;
    
    [self.view addSubview:volumeMenu];
    [volumeMenu updateVisualPosition:YES animated:NO];
}
-(void) startDelayedPlayback
{
   [self dispatchWithCategory:@"Player" andActionName:@"Video" andLabel:_video.name];
   [self playVideo:_video.playURLNormal];
}


-(void) addVideoPlayer
{
    // add player...
    player                       = [[MPMoviePlayerController alloc] init];
    player.movieSourceType       = MPMovieSourceTypeStreaming;
    player.shouldAutoplay        = YES;
    player.controlStyle          = MPMovieControlStyleNone;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    player.view.frame            = CGRectMake(CGRectZero.origin.x, CGRectZero.origin.y, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame));
    player.view.userInteractionEnabled = NO;
    player.view.backgroundColor = [UIColor blackColor];
    
    NSLog(@"ContainerView = %@", NSStringFromCGRect([containerView frame]));
    
    if (![containerView.subviews containsObject:player.view])
        [containerView addSubview:player.view];
    [self performSelector:@selector(startDelayedPlayback) withObject:nil afterDelay:0.5f];
    
    
    // show rate...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value          = [defaults objectForKey:@"banner_count"];
    int count = (int)value.integerValue;
    if(count > RATE_COUNT)
    {
        if([defaults boolForKey:@"isRated"] == NO)
        {
            [self showRate];
        }
    }
  
    self.thumbnailView.layer.zPosition  = containerView.layer.zPosition - 2;
    self.loadingView.layer.zPosition = self.thumbnailView.layer.zPosition + 1;
}


-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)toggleHD:(BOOL)hd
{
    quality = hd;
    if(quality == YES)
    {
        [self playVideo:_video.playURLHD];
    }
    else
    {
        [self playVideo:_video.playURLNormal];
    }
}

-(IBAction) changeQuality:(UIButton *) button
{
    button.selected = !quality;
    
    if(button.selected)
    {
          [self playVideo:_video.playURLHD];
           quality = YES;
    }
    else
    {
         [self playVideo:_video.playURLNormal];
        quality = NO;
    }
}

-(void) addToHistory
{
    [self addHistory];
    return;
    
  /*  NSLog(@"----------------");
    NSLog(@"%f",player.duration);
    NSLog(@"%f",player.currentPlaybackTime);
    NSLog(@"%f",player.duration - player.currentPlaybackTime);
    NSLog(@"%f",player.duration / 2.0f);
    NSLog(@"----------------");
   */
    User *user = (User *)[[GSUserSync sharedInstance] getSavedUser];
    
    if (user)
    {
       // if(player.duration > 0)
        //{
        
//            if (player.duration - player.currentPlaybackTime < player.duration / 2.0f)
//            {
               NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                              NULL,
                                                                                              (CFStringRef)_video.videoID,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 ));
            
                
        
            NSString *link =[NSString stringWithFormat:@"%@?id=%d&method=add&value=%@",HISTORY_URL,user.user_id,encodedString];
        
                [[SMServerAPI sharedInstance] performMethod:link
                                               withDelegate:self
                                                andCallback:@selector(historyResult:)];
           // }
      //  }

    }
}

-(void) historyResult:(NSDictionary *)history
{
    NSLog(@"%@",history);
}


-(void)addHistory
{
    NSMutableArray *histories;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = (NSArray *)[userDefaults objectForKey:@"myHistory"];
    if(arr != nil)
        histories = [[NSMutableArray alloc] initWithArray: arr];
    else
        histories = [[NSMutableArray alloc] init];

    // save
    if(![histories containsObject:_video.vid])
    {
        [histories insertObject:_video.vid atIndex:0];
        if(histories.count > 100)
            [histories removeLastObject];
        [userDefaults setObject:histories forKey:@"myHistory"];
    }
}


#pragma mark - Swipe

-(void) addTapHandler
{
    /*
    // swipe left, right
    UISwipeGestureRecognizer *prev = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    prev.direction                 = UISwipeGestureRecognizerDirectionLeft;
    prev.cancelsTouchesInView      = NO;
    [containerView addGestureRecognizer:prev];
    
    UISwipeGestureRecognizer *next = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    next.direction                 = UISwipeGestureRecognizerDirectionRight;
    next.cancelsTouchesInView      = NO;
    [containerView addGestureRecognizer:next];
    */
    
    // pinch gesture
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPinch:)];
    [containerView addGestureRecognizer:twoFingerPinch];
    
    //swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    //[containerView addGestureRecognizer:swipeGesture];
    
}


#pragma mark -

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture //Your action method
{
    
    CGPoint translation, velocity;
    switch(panGesture.state) {
        case UIGestureRecognizerStateChanged:
            translation = [panGesture translationInView:self.view];
            player.view.center = CGPointMake(self.view.frame.size.width / 2 + translation.x, self.view.frame.size.height / 2);
            
            
            break;
        case UIGestureRecognizerStateBegan:
            [panGesture setTranslation:CGPointZero inView:self.view];
            
            break;
        case UIGestureRecognizerStateEnded:
            velocity = [panGesture velocityInView:self.view];
            // The user lifted their fingers. Optionally use the velocity to continue rotating the globe automatically
            if (player.view.center.x > self.view.frame.size.width / 2)
            {
                if (velocity.x > 0) {
                    [containerView removeGestureRecognizer:swipeGesture];
                    [self swipeRight];
                } else {
                    [UIView animateWithDuration:0.3f animations:^{
                        player.view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
                    }];
                }
            } else {
                if (velocity.x > 0) {
                    [UIView animateWithDuration:0.3f animations:^{
                        player.view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
                    }];
                } else {
                    [containerView removeGestureRecognizer:swipeGesture];
                    [self swipeLeft];
                }
            }
            
            break;
            
        default:
            break;
    }
}


// swipe next, prev
-(void)swipeLeft
{
    
    if(!menuView.hidden) return;
    if(_index == _dataSource.count - 1) {
        [UIView animateWithDuration:0.3f animations:^{
            player.view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        } completion:^(BOOL finished) {
            swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            swipeGesture.cancelsTouchesInView      = NO;
            [containerView addGestureRecognizer:swipeGesture];
        }];
        return;
    }
    
    if(player.playbackState == MPMoviePlaybackStatePlaying) [player pause];
    //if(player.playbackState != MPMoviePlaybackStatePlaying) return;
    [self stopTimer];
    
    // animation player
    [UIView animateWithDuration:0.3f animations:^{
        player.view.center = CGPointMake(-self.view.frame.size.width/2, self.view.frame.size.height/2);
    }];
    
    // load next video
    [self nextVideo];
}

-(void)swipeRight
{
    if(!menuView.hidden) return;

    if(_index == 0)
    {
        [UIView animateWithDuration:0.3f animations:^{
            player.view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        } completion:^(BOOL finished) {
            swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            swipeGesture.cancelsTouchesInView      = NO;
            [containerView addGestureRecognizer:swipeGesture];
        }];
        return;
    }
    
    
    if(player.playbackState == MPMoviePlaybackStatePlaying) [player pause];
    [self stopTimer];
    
    // animation player
    [UIView animateWithDuration:0.3f animations:^{
        player.view.center = CGPointMake(self.view.frame.size.width*3/2, self.view.frame.size.height/2);
    }];
  

    // load previous video
    [self prevVideo];
}

-(void) nextVideo
{
    if(_index == _dataSource.count - 1) return;
    
    [self shouldAddBanner];
    // get next video...
    _index++;
    Video *currentVideo = [_dataSource objectAtIndex:_index];
    _video              = currentVideo;
    
    [infoView updateVideo:_video];
    
    if(!quality)
        [self playVideo:_video.playURLNormal];
    else
        [self playVideo:_video.playURLHD];
    [self dispatchWithCategory:@"Player" andActionName:@"Video" andLabel:_video.name];
    
    
    // set thumbnail
    [self closeMenu];
    [self performSelectorOnMainThread:@selector(setThumbnailImage:) withObject:[NSString stringWithFormat:@"%d", (int)_index] waitUntilDone:0.5];
    
    
    // next dataSource
    if(_index == _dataSource.count -2)
    {
        [_delegate nextStepVideo];
    }
}

-(void) prevVideo
{
    if(_index == 0) return;
    
    [self shouldAddBanner];

    _index--;
    Video *currentVideo = [_dataSource objectAtIndex:_index];
    _video              = currentVideo;
    
    [infoView updateVideo:_video];
    
    if(!quality)
        [self playVideo:_video.playURLNormal];
    else
        [self playVideo:_video.playURLHD];
    [self dispatchWithCategory:@"Player" andActionName:@"Video" andLabel:_video.name];
    
    // set thumbnail
    [self closeMenu];
    [self performSelectorOnMainThread:@selector(setThumbnailImage:) withObject:[NSString stringWithFormat:@"%d", (int)_index] waitUntilDone:0.5];
}


-(void)setThumbnailImage:(NSString *)strIndex
{
    
    Video *nextVideo = (Video *)[_dataSource objectAtIndex:(int)[strIndex integerValue]];
    NSURL *url = [NSURL URLWithString: nextVideo.ThumbnailLargeURL];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    self.thumbnailView.image = [UIImage imageWithData:imageData];
    self.loadingView.hidden = NO;
}


-(void) playVideo:(NSURL *) videoURL
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    
    /*if([self shouldAddBanner])
    {
        if(![self.view.subviews containsObject:bannerView])
        {
            if ([[[UIDevice currentDevice] model] containsString:@"iPad"] == true)
                bannerView  = (BannerView * ) [[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:10] ;
            else
                bannerView  = (BannerView * ) [[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] objectAtIndex:6] ;
            bannerView.delegate = self;
            
            [self.view addSubview:bannerView];
            [bannerView updateVisualPosition:YES animated:NO];
        }
    }*/
    
    [timeMenu setupSlider];
    [player setContentURL:videoURL];
    [player prepareToPlay];
    [player play];
    [player.view setHidden:NO];
    
    [defaultCenter addObserver:self selector:@selector(playbackStateChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
    [defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [defaultCenter addObserver:self selector:@selector(durationAvailable:)    name:MPMovieDurationAvailableNotification            object:player];
    [defaultCenter addObserver:self selector:@selector(movieLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    
    [playMenu changeButtonState:YES];
    
    if (extrasView.autoCasting)
    {
        if (self.selectedDevice != nil)
            [self castVideo:nil];
    }
    
    
    [avatarImage setImageWithURL:[NSURL URLWithString:_video.userProfilePictureURL] placeholderImage:[UIImage imageNamed:@"avatar_user_placeholder"]];
    
    if(_video.userName && ([_video.userName isEqualToString:@""] == false)){
        avatarName.text = _video.userName;
    }
    else{
        avatarName.text = @"youtuber";
    }
    videoName.text = _video.name;
   
    [self adjustVideoNameLabels];
   
    // add into history
    [self addToHistory];
}



#pragma mark - cast
-(void) startCast
{
    self.deviceScanner = [[GCKDeviceScanner alloc] init];
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
}


#pragma mark - show
-(void) showView:(UIView *) view onScreen:(BOOL) onScreen
{
    if ([view isEqual:infoView])
    {
        [infoView       updateVisualPosition:onScreen animated:YES];
        [extrasView     updateVisualPosition:YES animated:NO];
        [channelsView   updateVisualPosition:YES animated:NO];
        [watchView       updateVisualPosition:YES animated:NO];
        [saveView   updateVisualPosition:YES  animated:NO];
    }
    else  if ([view isEqual:extrasView])
    {
        [infoView       updateVisualPosition:YES animated:NO];
        [extrasView     updateVisualPosition:onScreen  animated:YES];
        [channelsView   updateVisualPosition:YES animated:NO];
        [watchView       updateVisualPosition:YES animated:NO];
        [saveView   updateVisualPosition:YES  animated:NO];
    }
    else  if ([view isEqual:channelsView])
    {
        [infoView       updateVisualPosition:YES animated:YES];
        [extrasView     updateVisualPosition:YES animated:NO];
        [channelsView   updateVisualPosition:onScreen  animated:YES];
        [watchView       updateVisualPosition:YES animated:NO];
        [saveView   updateVisualPosition:YES  animated:NO];
    }
    else  if ([view isEqual:shareView])
    {
        [self openShare];
    }
    else if ([view isEqual: watchView])
    {
        [infoView       updateVisualPosition:YES animated:NO];
        [extrasView     updateVisualPosition:YES animated:NO];
        [channelsView   updateVisualPosition:YES  animated:NO];
        [watchView       updateVisualPosition:onScreen animated:YES];
        [saveView   updateVisualPosition:YES  animated:NO];
    }
    else if ([view isEqual: saveView])
    {
        [infoView       updateVisualPosition:YES animated:NO];
        [extrasView     updateVisualPosition:YES animated:NO];
        [channelsView   updateVisualPosition:YES  animated:NO];
        [saveView       updateVisualPosition:onScreen animated:YES];
        [watchView   updateVisualPosition:YES  animated:NO];
    }
}


#pragma mark - play menu delegate
-(void)viewWillDisappear:(BOOL)animated
{
    [self stopActions];
}

-(IBAction)playMenuInfoShow
{
    if(infoView.onScreen) return;
 
    menuView.hidden = YES;
    [self closeShare];
    [infoView updateVideo:_video];
    [self showView:infoView onScreen:infoView.onScreen];
}

-(void)playMenuShareShow
{
    [shareView setVideo:_video];
    [self showView:shareView onScreen:infoView.onScreen];
}


-(void)playMenuPlusShow:(BOOL)show
{
    [self showView:channelsView onScreen:channelsView.onScreen];
}

-(void)playMenuSendPlaylist
{
   [self stopActions];
   if ([_delegate respondsToSelector:@selector(playerPressedBack)])
    {
        [_delegate playerPressedBack];
    }
   
    [self takeScreenShot];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(IBAction)playMenuUserShow
{
    if(extrasView.onScreen) return;
    
    menuView.hidden = YES;
    [self closeShare];
    [self showView:extrasView onScreen:extrasView.onScreen];
}


-(IBAction)playMenuSaveShow
{
    menuView.hidden = YES;
    [self closeShare];
    [self showView:saveView onScreen:saveView.onScreen];
}

-(IBAction)playMenuWatchShow
{
    menuView.hidden = YES;
    [self closeShare];
    [self showView:watchView onScreen:watchView.onScreen];
}


-(IBAction)onClickURL:(id)sender
{
    [[UIApplication sharedApplication] openURL:player.contentURL];
}


// ------------------------------------------------------------------------------------------------------------------------
// Search
// ------------------------------------------------------------------------------------------------------------------------

-(IBAction)playMenuSearchShow
{
    menuView.hidden = YES;
    [self closeShare];
    self.searchView.hidden = NO;
    self.searchView.frame = CGRectMake(0, -self.searchView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"searchView.frame = %@", NSStringFromCGRect(self.searchView.frame));
    
    [UIView animateWithDuration:0.5f animations:^{
        self.searchView.frame = CGRectMake(0, 0, self.searchView.frame.size.width, self.view.frame.size.height);
        NSLog(@"searchView.frame = %@", NSStringFromCGRect(self.searchView.frame));
    }];
    
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.6];
}
     
-(void)showKeyboard
{
    [self.txtSearch becomeFirstResponder];
}

-(IBAction)onExitSearch:(id)sender
{
    [self.txtSearch resignFirstResponder];
    [self performSelector:@selector(hideSearch) withObject:nil afterDelay:0.6];
    [UIView animateWithDuration:0.5f animations:^{
        self.searchView.frame = CGRectMake(0, -self.searchView.frame.size.height, self.searchView.frame.size.width, self.searchView.frame.size.height);
        NSLog(@"searchView.frame = %@", NSStringFromCGRect(self.searchView.frame));
    }];
}

-(void)hideSearch
{
    self.searchView.hidden = YES;
}

-(void) startSearch:(NSString *) keyword
{
    [self stopActions];
    if ([_delegate respondsToSelector:@selector(playerInitiatedSearch:)])
    {
        [_delegate playerInitiatedSearch:keyword];
    }
    
    self.searchView.hidden = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text isEqualToString:@""]) return false;
    
    // remove search view
    self.searchView.frame = CGRectMake(0, 0, self.searchView.frame.size.width, self.searchView.frame.size.height);
    NSLog(@"searchView.frame = %@", NSStringFromCGRect(self.searchView.frame));
    [UIView animateWithDuration:0.5f animations:^{
        self.searchView.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        NSLog(@"searchView.frame = %@", NSStringFromCGRect(self.searchView.frame));
    }];

    
    [self performSelector:@selector(startSearch:) withObject:textField.text afterDelay:0.3];
    return true;
}

// ------------------------------------------------------------------------------------------------------------------------
// Menu buttons
// ------------------------------------------------------------------------------------------------------------------------

-(void)playMenuPlay:(BOOL)pause
{
    if (pause)
       [player pause];
    else {
        [player play];
        [self.bufferingView setHidden:YES];
    }
}

-(void)playMenuPrev
{
    if(_index == 0) return;
    if(player.playbackState != MPMoviePlaybackStatePlaying) return;
    
    // animation player
    [UIView animateWithDuration:0.3f animations:^{
        player.view.center = CGPointMake(-self.view.frame.size.width*3/2, self.view.frame.size.height/2);
    }];

    [self prevVideo];
}

-(void)playMenuNext
{
    if(_index == _dataSource.count - 1) return;
    if(player.playbackState != MPMoviePlaybackStatePlaying) return;
    
    // animation player
    [UIView animateWithDuration:0.3f animations:^{
        player.view.center = CGPointMake(-self.view.frame.size.width/2, self.view.frame.size.height/2);
    }];
    
    
    // load next video
    [self nextVideo];
}

#pragma mark - video
-(void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    if(bPinch) return;
    if ([notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue] == 0)
    {
        [self nextVideo];
    }
    
}

-(void)movieLoadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled	        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    MPMovieLoadState loadState = player.loadState;
    
    if ((loadState & MPMovieLoadStatePlaythroughOK) != 0) {
        [self.bufferingView setHidden:YES];
    } else if ((loadState & MPMovieLoadStateStalled) != 0) {
        [self.bufferingView setHidden:NO];
    }
    
    NSLog(@"loadStateDidChange %d", (int)(long)player.loadState);
}


-(void)playbackStateChanged
{
    MPMoviePlaybackState playbackState = player.playbackState;
    //NSLog(@"Playback");
    
    NSLog(@"playbackStateChanged: containerView = %@", NSStringFromCGRect(containerView.frame));
    NSLog(@"playbackStateChanged: super view = %@", NSStringFromCGRect(self.view.frame));
    
    if (playbackState == MPMoviePlaybackStateInterrupted)
    {
        //pause timer
        //NSLog(@"MPMoviePlaybackStateInterrupted");
        //[self stopTimer];
        
    }
    if(playbackState == MPMovieFinishReasonPlaybackEnded)
    {
        //[self nextVideo];
        
    }
    if (playbackState == MPMoviePlaybackStatePaused)
    {
        [self updateVisualState:NO];
    }
    if (playbackState == MPMoviePlaybackStatePlaying)
    {
        [self closeShare];
        [self closeMenu];
        [self updateVisualState:YES];
        
        // change the player frame...
        [self performSelector:@selector(hideThumbnail) withObject:nil afterDelay:1.0];
    }
    
    if (playbackState == MPMoviePlaybackStateStopped)
    {
        //NSLog(@"MPMoviePlaybackStateStopped");
        //[self stopTimer];
    }
}

-(void)hideThumbnail
{
    self.loadingView.hidden = YES;
    self.thumbnailView.image = nil;
    player.view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    
    swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    swipeGesture.cancelsTouchesInView      = NO;
    [containerView addGestureRecognizer:swipeGesture];
}


-(void) durationAvailable:(NSNotification *) notification
{  
    [timeMenu setMaximumValue:player.duration];
    
    
    videoSlider.maximumValue = player.duration;
    long duration = (long) player.duration;
    int currentHours   = (int)(duration / 3600);
    int currentMinutes = (int)((duration / 60) - currentHours*60);
    int currentSeconds = (int)(duration % 60);
    
    if (currentHours > 0)
    {
        videoTime.text = [NSString stringWithFormat:@"00:00:00 / %02d:%02d:%02d",currentHours,currentMinutes, currentSeconds];
    }
    else
    {
        videoTime.text = [NSString stringWithFormat:@"00:00:00 / 00:%02d:%02d",currentMinutes, currentSeconds];
    }
    
    [self startTimer];
    [self hideThumbnail];
    [self closeShare];
    [self closeMenu];
    [self updateVisualState:YES];
}


#pragma mark - states
-(void) updateVisualState:(BOOL) state
{
    [playMenu changeButtonState:state];
    [timeMenu changeTimerState:state];
}
#pragma mark - time
-(void)timeMenuUpdateWithCurrentValue:(NSTimeInterval)timeInterval
{
    [player setCurrentPlaybackTime:timeInterval];
}
#pragma mark - tracker
-(void)dispatchWithCategory:(NSString *)categoryName andActionName:(NSString *)actionName andLabel:(NSString *)labelName
{
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:categoryName
                                            action:actionName
                                             label:labelName
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

#pragma mark - login
-(BOOL)checkLogin:(NSString *)name
{
    if([name isEqualToString:@"Facebook"] || [name isEqualToString:@"History"])
    {
        User *user = [[GSUserSync sharedInstance] getSavedUser];
        if(!user)
        {
            [player pause];
            [self performSegueWithIdentifier:@"account_segue" sender:self];
        
            return NO;
        }
    }
    return YES;
}




#pragma mark - delegates
-(void) mailComposeController: (MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed – Unknown Error " delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            
            break;
    }
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    [player play];
}

-(void)copyLink
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = (NSString *)[[player contentURL] absoluteString];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copy Link" message:@"The video url was copied." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)clickSave
{
    [self playMenuSaveShow];
}

-(void)clickThumbler
{
    [self playMenuWatchShow];
}


- (void) setProducts:(NSArray *)list
{
    products = [[NSArray alloc] initWithArray:list];
}

- (NSArray *) getProducts
{
    return products;
}

- (IBAction)onBackward:(id)sender {
    [playMenu prev:nil];
}

- (IBAction)onPlayPause:(id)sender {
    [playMenu play_pause:playMenu.playButton];
}

- (IBAction)onForward:(id)sender {
    [playMenu next:nil];
}

- (IBAction)onID1:(id)sender {
    [playMenu showInfo:nil];
}

#pragma mark - ShareMenuDelegate



// ----------------------------------------------------------------------------------------------------------------
// Send Email
// ----------------------------------------------------------------------------------------------------------------

- (void) sendEmail:(NSString *)body
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [picker setSubject: @"Have you seen this? Found on iSofa.tv"];
        [picker setMessageBody: body isHTML:YES];
        [self presentViewController:picker animated:YES completion:nil];
        
        [player pause];
    }
}

// ----------------------------------------------------------------------------------------------------------------
// Google Signin
// ----------------------------------------------------------------------------------------------------------------

-(void)onGoogleSignin
{
    GIDSignIn* signIn = [GIDSignIn sharedInstance];
    //    if (self.fetchEmailToggle.isEnabled) {
    //        signIn.shouldFetchBasicProfile = YES;
    //    }
    signIn.clientID = kClientId;
    signIn.scopes = @[ @"profile", @"email" ];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - google sigin delegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    //self.statusField.text = @"Signed in user";
    
    [shareView showGooglePlusShare];
}
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    //self.statusField.text = @"Disconnected user";
}


#pragma mark - GIDSignInUIDelegate
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    
}

// If implemented, this method will be invoked when sign in needs to display a view controller.
// The view controller should be displayed modally (via UIViewController's |presentViewController|
// method, and not pushed unto a navigation controller's stack.
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

// If implemented, this method will be invoked when sign in needs to dismiss a view controller.
// Typically, this should be implemented by calling |dismissViewController| on the passed
// view controller.
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end


