//
//  Downloader.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 24/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "Downloader.h"
#import "SMServerAPI.h"
#import "FacebookService.h"
#import <FacebookSDK/FacebookSDK.h>

static Downloader *instance;

@implementation Downloader

+(Downloader *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[Downloader alloc] init];
        
    }
    
    return instance;
}
-(void)requestDataWithType:(RequestType)type andText:(NSString *)text
{
    parser = [Parser sharedInstance];
    parser.delegate = _delegate;
    switch(type)
    {
        case kRequestTypeFacebook:
        {
            [self loadFacebook];
        }
            break;
        case kRequestTypeChannel:
        {
            
        }
            break;
        case kRequestTypeHistory:
        {
            
        }
            break;
        case kRequestTypeSearch:
        {
            
        }
            break;
        case kRequestTypeYoutubeBest:
        {
            [self loadBestYoutubeVideos];
        }
            break;
    }
}
#pragma mark  -
#pragma mark - youtube best
- (void) loadBestYoutubeVideos
{
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=10&key=%@", GOOGLE_API_KEY];
    [[SMServerAPI sharedInstance] performMethod:url withDelegate:self andCallback:@selector(youtubeRequestReceivedWithInfo:)];
}
- (void) youtubeRequestReceivedWithInfo:(NSDictionary *) info
{

 //   [parser parseYoutubeVideos:[info objectForKey:@"items"]];
    [NSThread detachNewThreadSelector:@selector(parseYoutubeVideos:) toTarget:parser withObject:[info objectForKey:@"items"]];

}
#pragma mark  -
#pragma mark - facebook acces
-(void)requestAccessToken
{
    [[FacebookService sharedService] requestReadPermissionsWithBlock:^(BOOL succes, NSError *error) {
        if (succes)
        {
            accessToken = [FBSession activeSession].accessTokenData.accessToken;
            [self loadFacebook];
        }
        else
        {
            //[self loadBestYoutubeVideos];
        }
    }];
}
- (void) loadFacebook
{
    if (!accessToken)
    {
        [self performSelectorOnMainThread:@selector(requestAccessToken) withObject:nil waitUntilDone:YES];
        return;
    }
    
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@&access_token=%@&", GRAPH_REQUEST, accessToken];
    
    [[SMServerAPI sharedInstance] performMethod:url withDelegate:self andCallback:@selector(facebookRequestRecievedWithInfo:)];
}
- (void) facebookRequestRecievedWithInfo:(NSDictionary *) info
{
    [parser parseFacebookInformation:[[info objectForKey:@"home"] objectForKey:@"data"]];
    
}
@end
