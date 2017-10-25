//
//  PlayMenu.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "ShareMenu.h"
#import "UIImageView+WebCache.h"
//#import <GooglePlus/GooglePlus.h>
#import "FacebookService.h"
#import "Video.h"

#import <GoogleSignIn/GoogleSignIn.h>


@implementation ShareMenu

- (void) setVideo:(Video *) video
{
    currentVideo = video;
}


// ----------------------------------------------------------------------------------------------------------------
// Share Google+
// ----------------------------------------------------------------------------------------------------------------

- (IBAction) onClickGoogle:(UIButton *)sender
{
//    GPPSignIn *signIn = [GPPSignIn sharedInstance];
//    signIn.shouldFetchGooglePlusUser = YES;
//    
//    signIn.clientID = @"273042816169-t0th9esfjvemaukgd60j0nbtd3ip5hmk.apps.googleusercontent.com";
//    signIn.scopes = @[@"https://www.googleapis.com/auth/plus.login"];
//    signIn.delegate = self;
//    [signIn authenticate];
    
    [self.delegate onGoogleSignin];
   
}

- (void)showGooglePlusShare {
    
    NSURL *shareURL = nil;
    if(currentVideo.isFacebookVideo)
        shareURL = [NSURL URLWithString:currentVideo.videoID];
    else
        shareURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtu.be/%@",currentVideo.videoID]];
    
    // Construct the Google+ share URL
    NSURLComponents* urlComponents = [[NSURLComponents alloc]
                                      initWithString:@"https://plus.google.com/share"];
    urlComponents.queryItems = @[[[NSURLQueryItem alloc]
                                  initWithName:@"url"
                                  value:[shareURL absoluteString]]];
    NSURL* url = [urlComponents URL];
    
    [[UIApplication sharedApplication] openURL:url];
    
}


/*
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    [GPPShare sharedInstance].delegate = self;

//    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] shareDialog];
    
    [shareBuilder setContentDeepLinkID:@"test=1234567"];
    [shareBuilder setPrefillText:@"iSofa.tv is like a web tv. I found this amazing video there"];
    
    if(currentVideo.isFacebookVideo)
        [shareBuilder setURLToShare:[NSURL URLWithString:currentVideo.videoID]];
    else
        [shareBuilder setURLToShare:[NSURL URLWithString:[NSString stringWithFormat:@"http://youtu.be/%@",currentVideo.videoID]]];
    
    [shareBuilder setTitle:currentVideo.name description:currentVideo.descriptions thumbnailURL:[NSURL URLWithString:currentVideo.ThumbnailMediumURL]];
    [shareBuilder open];
}

-(void)finishedSharingWithError:(NSError *)error
{
    NSString *text;
    
    if (!error) {
        text = @"Post is succeeded.";
    } else if (error.code == kGPPErrorShareboxCanceled) {
        text = @"Post is canceled.";
    } else {
        text = [NSString stringWithFormat:@"Error (%@)", [error localizedDescription]];
    }
    
    NSLog(@"Status: %@", text);
}
*/


// ----------------------------------------------------------------------------------------------------------------
// Share Facebook
// ----------------------------------------------------------------------------------------------------------------

- (IBAction) onClickFacebook:(UIButton *)sender
{
    if(currentVideo.isFacebookVideo)
        [[FacebookService sharedService] postWithURL:[NSURL URLWithString:currentVideo.videoID]
                                            andTitle:[NSString stringWithFormat:@"www.iSofa.tv lis like a web tv. Have you seen this? %@ via %@ \n",currentVideo.name,currentVideo.userName] anDescription:currentVideo.name andPicture:[NSURL URLWithString:currentVideo.ThumbnailMediumURL]];
    else
        
        [[FacebookService sharedService] postWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://youtu.be/%@",currentVideo.videoID]]
                                            andTitle:[NSString stringWithFormat:@"www.iSofa.tv lis like a web tv. Have you seen this? %@ via %@ \n",currentVideo.name,currentVideo.userName] anDescription:currentVideo.name andPicture:[NSURL URLWithString:currentVideo.ThumbnailMediumURL]];
    
    /*
     SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
     
     [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://youtu.be/%@",currentVideo.videoID]]];
     
     [controller setInitialText:[NSString stringWithFormat:@"iSofa.tv is like a web tv. I found this amazing video there \n %@",currentVideo.name]];
     [(UIViewController *)_delegate presentViewController:controller animated:YES completion:Nil];
     
     // [[FacebookService sharedService] postWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com?watch=%@",currentVideo.videoID]]
     //                                   andTitle:currentVideo.name];*/
}

// ----------------------------------------------------------------------------------------------------------------
// Share Twitter
// ----------------------------------------------------------------------------------------------------------------

- (IBAction) onClickTwitter:(UIButton *)sender
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    if(currentVideo.isFacebookVideo)
        [controller addURL:[NSURL URLWithString:currentVideo.videoID]];
    else
        [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://youtu.be/%@",currentVideo.videoID]]];
    
    
    //[controller addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentVideo.ThumbnailMediumURL]]]];
    [controller setInitialText:[NSString stringWithFormat:@"www.iSofa.tv lis like a web tv. Have you seen this? %@ via %@ \n",currentVideo.name,currentVideo.userName]];
    [(UIViewController *)_delegate presentViewController:controller animated:YES completion:Nil];
}

// ----------------------------------------------------------------------------------------------------------------
// Send Email
// ----------------------------------------------------------------------------------------------------------------

- (IBAction) onClickEmail:(UIButton *)sender
{
    NSString *body;
    if (currentVideo.isFacebookVideo)
        body = [NSString stringWithFormat:@"iSofa.tv is like a web tv. I found this amazing video there: <br />  <a href='%@' >%@</a>",currentVideo.videoID,currentVideo.name];
    else
        body = [NSString stringWithFormat:@"iSofa.tv is like a web tv. I found this amazing video there: <br />  <a href='http://youtu.be/%@' >%@</a>",currentVideo.videoID,currentVideo.name];
    
    [self.delegate sendEmail:body];
}

- (IBAction) onCopyLink:(UIButton *)sender
{
    [self.delegate copyLink];
}

- (IBAction) onThumbler:(UIButton *)sender
{
    [self.delegate clickThumbler];
}

- (IBAction) onClickSave:(UIButton *)sender
{
    [self.delegate clickSave];
}

@end
