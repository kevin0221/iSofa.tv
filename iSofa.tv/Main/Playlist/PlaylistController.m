//  PlaylistController.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "PlaylistController.h"
#import "Video.h"
#import "UIImageView+WebCache.h"
#import "CustomHUD.h"
#import "SMServerAPI.h"
#import "ExtrasView.h"
#import "User.h"
#import "GSUserSync.h"
#import "PlaylistCell.h"
#import <QuartzCore/QuartzCore.h>


@interface PlaylistController ()
{
    IBOutlet CustomHUD *screenLocker;
    NSString *lastURL;
    SEL      callback;
    NSMutableArray *pageArray;
    NSString *nextPage;
    NSString *my_keyword;
    
    int start;
    int end;
    IBOutlet UICollectionView *collectionSource;
    NSString *my_channel;
}

@end

@implementation PlaylistController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Playlist";
    pageArray = [NSMutableArray array];
    dataSource = [NSMutableArray array];
   [self showActivity];
   
    end = 10;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [self showActivity];
    [self playerPressedPlaylist];
    
    // backgroundView
    if(backgroundView ==  nil)
        backgroundView = [[UIImageView alloc] init];
}

// screen capture...
-(void)twoFingerPinch:(UIPinchGestureRecognizer *)pinch
{
    if(!bPinch && arrChannels.count > 0)
    {
        bPinch = true;
        [self performSegueWithIdentifier:@"goChannels" sender:self];
    }
}


-(IBAction)onBack:(id)sender
{
    if(!screenLocker.hidden) return;
    if(arrChannels.count > 0)
        [self performSegueWithIdentifier:@"goChannels" sender:self];
}

-(void)viewDidLayoutSubviews
{
    // update CollectionView layout...
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionSource.collectionViewLayout;
    layout.headerReferenceSize = CGSizeZero;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    collectionSource.backgroundView.alpha = 0.5;
    collectionSource.backgroundView = backgroundView;
    collectionSource.collectionViewLayout = layout;
}

-(void)viewWillAppear:(BOOL)animated
{
    // pinch gesture
    bPinch = false;
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPinch:)];
    [self.view addGestureRecognizer:twoFingerPinch];
    
    // animation...
    [super viewWillAppear:animated];
    [self animationCollectionView];
}

-(void)animationCollectionView
{
    collectionSource.transform = CGAffineTransformMakeScale(20.0, 20.0);
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        collectionSource.transform = CGAffineTransformMakeScale(1.0, 1.0);
        collectionSource.center = self.view.center;
        
        // playlist --> player
        if(![strSearchChannel isEqualToString:@""])
        {
            // reset collectionView
            dataSource = [[NSMutableArray alloc] init];
            [collectionSource reloadData];
            
            // select channel
            [self selectChannel:strSearchChannel];
        }
    } completion: nil];
}


- (void) refresh
{
    if(lastURL != nil && callback != NULL)
    {
        [self initRequest];
        [dataSource removeAllObjects];
         [[SMServerAPI sharedInstance] performURL:lastURL withDelegate:self andCallback:callback];
    }
}

-(void)playerPressedBack
{
    [self refresh];
}

-(void)getChannelslist
{
    if(arrChannels.count > 0) return;
    [[SMServerAPI sharedInstance] performURL:CHANNELS_URL withDelegate:self andCallback:@selector(channels:)];
}

- (void) channels:(NSArray *) channels
{
    arrChannels = [NSMutableArray arrayWithArray:channels];
    [self openInitialBest];
}

- (void) openInitialBest
{
    channelName.text = @"iSofa.tv Experience";
    //User *user = [[GSUserSync sharedInstance] getSavedUser];
    
    lastURL    = [NSString stringWithFormat:@"%@%@",BASE_URL,BEST_YOUTUBE_PATH];
    callback   = @selector(newVideos:);
    [[SMServerAPI sharedInstance] performURL:lastURL withDelegate:self andCallback:callback];
}

/* KCI
- (void) nextPageSearch
{
    [self dispatchWithCategory:@"Main Playlist" andActionName:@"Youtube Search" andLabel:my_keyword];
    [self initRequest];
    
    lastURL    = [NSString stringWithFormat:@"%@?maxResults=%d&query=%@&nextPage=%@",SEARCH_URL,10,[my_keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],nextPage];
    callback = @selector(newSearchVideos:);
    [[SMServerAPI sharedInstance] performURL:lastURL withDelegate:self andCallback:callback];
}*/

- (void) nextPageSearch
{
    [self dispatchWithCategory:@"Main Playlist" andActionName:@"Youtube Search" andLabel:my_keyword];
    [self initRequest];
    
    lastURL    = [NSString stringWithFormat:@"%@%@?query=%@&token=%@",BASE_URL,SEARCH_URL,[my_keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],nextPage];
    callback = @selector(newVideos:);
    [[SMServerAPI sharedInstance] performURL:lastURL withDelegate:self andCallback:callback];
}

- (void) initRequest
{
    [self showActivity];
     collectionSource.userInteractionEnabled = NO;
}

- (void) closeRequest
{
    [self hideActivity];
    collectionSource.userInteractionEnabled = YES;
}


- (IBAction) searchForKeyword:(NSString *) keyword
{
    [self dispatchWithCategory:@"Main Playlist" andActionName:@"Youtube Search" andLabel:keyword];
    [self resetRequest];
    [self initRequest];
    
    [dataSource removeAllObjects];
    [collectionSource reloadData];
    my_keyword = keyword;
    lastURL    = [NSString stringWithFormat:@"%@%@?query=%@",BASE_URL,SEARCH_URL,[keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    callback   = @selector(newVideos:);
    [[SMServerAPI sharedInstance] performURL:lastURL withDelegate:self andCallback:callback];
}


- (void) nextFacebookStep
{
    User *user = [[GSUserSync sharedInstance] getSavedUser];
    [self initRequest];
    
    lastURL    = [NSString stringWithFormat:@"%@?accessToken=%@&id=%d&start=%d&end=%d",FB_URL,user.facebook_id,user.user_id,start,end];
    callback   = @selector(newFBVideos:);
    SMServerAPI *api = [SMServerAPI new];
    [api performURL:lastURL withDelegate:self andCallback:callback];
    
    
    if([channelName.text rangeOfString:@"iSofa.tv Experience"].length > 0)
    {
        lastURL    = [NSString stringWithFormat:@"%@&id=%d",LOCAL_URL,user.user_id];
        callback   = @selector(newVideos:);
    }
}


- (void)settingsLoadedAccessToken
{
    //NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    User *user = [[GSUserSync sharedInstance] getSavedUser];
    
    
    lastURL    = [NSString stringWithFormat:@"%@?accessToken=%@&id=%d&start=%d&end=%d",FB_URL,user.facebook_id,user.user_id,start,end];
    callback   = @selector(newFBVideos:);
    
    SMServerAPI *api = [SMServerAPI new];
    [api performURL:lastURL withDelegate:self andCallback:callback];
    if([channelName.text rangeOfString:@"iSofa.tv Experience"].length > 0)
    {
        lastURL    = [NSString stringWithFormat:@"%@&id=%d",LOCAL_URL,user.user_id];
        callback   = @selector(newVideos:);
    }
}

- (void) settingsError
{
    // show alert
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iSofa" message:@"Nops, zero results" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
    
    strSearchChannel = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) newFBVideos:(NSArray *) list
{
    if (list.count > 0)
    {
        for (NSDictionary *vid in list)
        {
            Video *newvideo = [Video new];
            
            newvideo.videoID            =  vid[@"id"];
            newvideo.name               =  vid[@"title"];
            newvideo.vid                =  vid;
            
            if ([vid objectForKey:@"thumbnail"])
            {
                newvideo.ThumbnailMediumURL =  [vid objectForKey:@"thumbnail"];
            }
            newvideo.descriptions       =  vid[@"description"];
            newvideo.date               =  vid[@"published"];
            if(![[vid objectForKey:@"duration"] isKindOfClass:[[NSNull null] class]])
                newvideo.duration           =  [[vid objectForKey:@"duration"] intValue];
            if(![[vid objectForKey:@"view_count"] isKindOfClass:[[NSNull null] class]])
                newvideo.views              =  [[vid objectForKey:@"view_count"] intValue];
            
            if (![[[vid objectForKey:@"user"] objectForKey:@"name"] isKindOfClass:[[NSNull null] class]])
                newvideo.userName              = [[vid objectForKey:@"user"] objectForKey:@"name"];
            if (![[[vid objectForKey:@"user"] objectForKey:@"avatar"] isKindOfClass:[[NSNull null] class]])
                newvideo.userProfilePictureURL = [[vid objectForKey:@"user"] objectForKey:@"avatar"];
            
            newvideo.isFacebookVideo       = [[vid objectForKey:@"facebook"] boolValue];
            
            NSDictionary *videos        =  [vid objectForKey:@"videos"];
            if(![videos isKindOfClass:[[NSNull null] class]])
            {
                NSString *small_url         =  [videos objectForKey:@"small"];
                NSString *medium_url        =  [videos objectForKey:@"medium"];
                NSString *hd_url            =  [videos objectForKey:@"hd720"];
                
                if (medium_url)
                {
                    newvideo.playURLNormal = [NSURL URLWithString:medium_url];
                }
                
                if (hd_url)
                {
                    newvideo.playURLHD = [NSURL URLWithString:hd_url];
                }
                
                
                if (medium_url == nil)
                {
                   
                    if (small_url )
                    {
                         newvideo.playURLNormal = [NSURL URLWithString:small_url];
                    }
                    
                   
                }
                if(hd_url == nil)
                {
                    if (medium_url == nil)
                    {
                        
                        if (small_url )
                        {
                            newvideo.playURLHD = [NSURL URLWithString:small_url];
                        }
                        
                        
                    }
                    else
                    {
                       newvideo.playURLHD = [NSURL URLWithString:medium_url];
                    }
                }
            }
            
            
            if(![videos isKindOfClass:[[NSNull null] class]])
                [dataSource addObject:newvideo];
        }
        
        [collectionSource reloadData];
    }
    else
    {
        start = -1;
//        if([channelName.text rangeOfString:@"iSofa.tv Experience"].length == 0)
//        {
//            [self noResults];
//            
//            [self openInitialBest];
//        }
       
    }
    if(player)
    {
        player.dataSource = dataSource;
    }
    
    [self closeRequest];
}

- (void) newChannelVideos:(NSArray *) list
{
    if (list.count > 0)
    {
        for (NSDictionary *vid in list)
        {
            Video *newvideo = [Video new];
            
            newvideo.videoID            =  vid[@"id"];
            newvideo.name               =  vid[@"title"];
            newvideo.vid                =  vid;
            
            if ([vid objectForKey:@"thumbnails"])
            {
                newvideo.ThumbnailMediumURL =  [[vid objectForKey:@"thumbnails"]objectForKey:@"standard"];
                newvideo.ThumbnailLargeURL  =  [[vid objectForKey:@"thumbnails"]objectForKey:@"high"];
            }
            
            if([vid objectForKey:@"thumbnail"])
            {
                newvideo.ThumbnailMediumURL = [vid objectForKey:@"thumbnail"];
                newvideo.ThumbnailLargeURL  = [vid objectForKey:@"thumbnail"];
            }
            
            
            newvideo.descriptions       =  vid[@"description"];
            newvideo.date               =  vid[@"published"];
            if(![[vid objectForKey:@"duration"] isKindOfClass:[[NSNull null] class]])
                newvideo.duration           =  [[vid objectForKey:@"duration"] intValue];
            if(![[vid objectForKey:@"view_count"] isKindOfClass:[[NSNull null] class]])
                newvideo.views              =  [[vid objectForKey:@"view_count"] intValue];
            
            if (![[[vid objectForKey:@"user"] objectForKey:@"name"] isKindOfClass:[[NSNull null] class]])
                newvideo.userName              = [[vid objectForKey:@"user"] objectForKey:@"name"];
            if (![[[vid objectForKey:@"user"] objectForKey:@"avatar"] isKindOfClass:[[NSNull null] class]])
                newvideo.userProfilePictureURL = [[vid objectForKey:@"user"] objectForKey:@"avatar"];
            
            NSDictionary *videos        =  [vid objectForKey:@"videos"];
            if(![videos isKindOfClass:[[NSNull null] class]])
            {
                NSString *small_url         =  [videos objectForKey:@"small"];
                NSString *medium_url        =  [videos objectForKey:@"medium"];
                NSString *hd_url            =  [videos objectForKey:@"hd720"];
                
                if (medium_url)
                {
                    newvideo.playURLNormal = [NSURL URLWithString:medium_url];
                }
                
                if (hd_url)
                {
                    newvideo.playURLHD = [NSURL URLWithString:hd_url];
                }
                
                
                if (medium_url == nil)
                {
                    
                    if (small_url )
                    {
                        newvideo.playURLNormal = [NSURL URLWithString:small_url];
                    }
                    
                    
                }
                if(hd_url == nil)
                {
                    if (medium_url == nil)
                    {
                        
                        if (small_url )
                        {
                            newvideo.playURLHD = [NSURL URLWithString:small_url];
                        }
                        
                        
                    }
                    else
                    {
                        newvideo.playURLHD = [NSURL URLWithString:medium_url];
                    }
                }
            }
            
            
            if(![videos isKindOfClass:[[NSNull null] class]])
                [dataSource addObject:newvideo];
            
        }
        
        [collectionSource reloadData];
    }
    else
    {
        start = -1;
        
        [self noResults];
        [self playerPressedPlaylist];
    }
    
    if(player)
        player.dataSource = dataSource;

    
    [self firstVideoLoad];
    [self closeRequest];
}

- (void) noResults
{
    // show alert
    if([strSearchChannel isEqualToString:@"History"])
    {
        // show alert
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iSofa" message:@"There is no any history!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        // show alert
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iSofa" message:@"Nops, zero results" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
    
    // return channel list view
    if(![strSearchChannel isEqualToString:@""])
    {
        strSearchChannel = @"";
        [self performSegueWithIdentifier:@"goChannels" sender:self];
    }
}


- (void) newSearchVideos:(NSDictionary *) content
{
    NSArray *list = [content objectForKey:@"items"];
    nextPage      = [content objectForKey:@"nextPage"];
    if(nextPage) [pageArray addObject:nextPage];
    
    if (list.count > 0)
    {
        for (NSDictionary *vid in list)
        {
            Video *newvideo = [Video new];
            
            newvideo.videoID            =  vid[@"id"];
            newvideo.name               =  vid[@"title"];
            newvideo.vid                =  vid;
            
            if ([vid objectForKey:@"thumbnails"])
            {
                newvideo.ThumbnailMediumURL =  [[vid objectForKey:@"thumbnails"]objectForKey:@"standard"];
                newvideo.ThumbnailLargeURL  =  [[vid objectForKey:@"thumbnails"]objectForKey:@"high"];
            }
            
            newvideo.descriptions       =  vid[@"description"];
            newvideo.date               =  vid[@"published"];
            
            if(![[vid objectForKey:@"duration"] isKindOfClass:[[NSNull null] class]])
                newvideo.duration           =  [[vid objectForKey:@"duration"] intValue];
            if(![[vid objectForKey:@"view_count"] isKindOfClass:[[NSNull null] class]])
                newvideo.views              =  [[vid objectForKey:@"view_count"] intValue];
            
             if (![[[vid objectForKey:@"user"] objectForKey:@"name"] isKindOfClass:[[NSNull null] class]])
                 newvideo.userName              = [[vid objectForKey:@"user"] objectForKey:@"name"];
            if (![[[vid objectForKey:@"user"] objectForKey:@"avatar"] isKindOfClass:[[NSNull null] class]])
                 newvideo.userProfilePictureURL = [[vid objectForKey:@"user"] objectForKey:@"avatar"];
            
            NSDictionary *videos        =  [vid objectForKey:@"videos"];
            if(![videos isKindOfClass:[[NSNull null] class]])
            {
                NSString *small_url         =  [videos objectForKey:@"small"];
                NSString *medium_url        =  [videos objectForKey:@"medium"];
                NSString *hd_url            =  [videos objectForKey:@"hd720"];
                
                if (medium_url)
                {
                    newvideo.playURLNormal = [NSURL URLWithString:medium_url];
                }
                
                if (hd_url)
                {
                    newvideo.playURLHD = [NSURL URLWithString:hd_url];
                }
                
                if (medium_url == nil)
                {
                    
                    if (small_url )
                    {
                        newvideo.playURLNormal = [NSURL URLWithString:small_url];
                    }
                }
                
                if(hd_url == nil)
                {
                    if (medium_url == nil)
                    {
                        if (small_url )
                        {
                            newvideo.playURLHD = [NSURL URLWithString:small_url];
                        }
                        
                    }
                    else
                    {
                        newvideo.playURLHD = [NSURL URLWithString:medium_url];
                    }
                }
            }
            
            if(![videos isKindOfClass:[[NSNull null] class]]) [dataSource addObject:newvideo];
        }
        
        [collectionSource reloadData];
    }
    else
    {
        start = -1;
        [self noResults];
        [self playerPressedPlaylist];
    }
    
    if(player)
    {
        player.dataSource = dataSource;
    }
    
    [self firstVideoLoad];
    [self closeRequest];
}


- (void) newVideos:(NSDictionary *) data
{
    NSArray* list = nil;
    if(![data isKindOfClass:[NSArray class]])
        list = [data objectForKey:@"videos"];
    else
        list = (NSArray*) data;
    
    if(list.count == 0)
    {
        [self noResults];
        [self closeRequest];
        [collectionSource reloadData];
        return;
    }
    
    // get next page...
//    if([data objectForKey:@"pageToken"])
//        nextPage = [data objectForKey:@"pageToken"];
//    else
        nextPage = @"";
    
    
    NSArray *arrHistory = [[NSUserDefaults standardUserDefaults] objectForKey:@"myHistory"];
    if (list.count > 0)
    {
        for (NSDictionary *vid in list)
        {
            if([arrHistory containsObject:vid]) continue;
            if(![vid isKindOfClass:[[NSNull null] class]])
            {
                Video *newvideo = [Video new];
                newvideo.videoID            =  vid[@"id"];
                newvideo.name               =  vid[@"title"];
                newvideo.vid                =  vid;
                
                if ([vid objectForKey:@"thumbnails"])
                {
                    newvideo.ThumbnailMediumURL =  [[vid objectForKey:@"thumbnails"]objectForKey:@"standard"];
                    newvideo.ThumbnailLargeURL  =  [[vid objectForKey:@"thumbnails"]objectForKey:@"high"];
                }
                
                if([vid objectForKey:@"thumbnail"])
                {
                    newvideo.ThumbnailMediumURL = [vid objectForKey:@"thumbnail"];
                    newvideo.ThumbnailLargeURL  = [vid objectForKey:@"thumbnail"];
                }
                if(![[vid objectForKey:@"description"] isKindOfClass:[[NSNull null] class]])
                    newvideo.descriptions       =  vid[@"description"];
                if(![[vid objectForKey:@"published"] isKindOfClass:[[NSNull null] class]])
                    newvideo.date               =  vid[@"published"];
                if(![[vid objectForKey:@"duration"] isKindOfClass:[[NSNull null] class]])
                    newvideo.duration           =  [[vid objectForKey:@"duration"] intValue];
                if(![[vid objectForKey:@"viewCount"] isKindOfClass:[[NSNull null] class]])
                    newvideo.views              =  [[vid objectForKey:@"viewCount"] intValue];
                
                if (![[[vid objectForKey:@"user"] objectForKey:@"name"] isKindOfClass:[[NSNull null] class]])
                    newvideo.userName              = [[vid objectForKey:@"user"] objectForKey:@"name"];
                if (![[[vid objectForKey:@"user"] objectForKey:@"avatar"] isKindOfClass:[[NSNull null] class]])
                    newvideo.userProfilePictureURL = [[vid objectForKey:@"user"] objectForKey:@"avatar"];
                
                NSDictionary *videos        =  [vid objectForKey:@"videos"];
                if(![videos isKindOfClass:[[NSNull null] class]])
                {
                    NSString *small_url         =  [videos objectForKey:@"small"];
                    NSString *medium_url        =  [videos objectForKey:@"medium"];
                    NSString *hd_url            =  [videos objectForKey:@"hd720"];
                    
                    
                    
                    if (medium_url)
                    {
                        newvideo.playURLNormal = [NSURL URLWithString:medium_url];
                    }
                    
                    if (hd_url)
                    {
                        newvideo.playURLHD = [NSURL URLWithString:hd_url];
                    }
                    
                    
                    if (medium_url == nil)
                    {
                        if (small_url )
                        {
                            newvideo.playURLNormal = [NSURL URLWithString:small_url];
                        }
                    }
                    
                    if(hd_url == nil)
                    {
                        if (medium_url == nil)
                        {
                            if (small_url )
                            {
                                newvideo.playURLHD = [NSURL URLWithString:small_url];
                            }
                        }
                        else
                        {
                            newvideo.playURLHD = [NSURL URLWithString:medium_url];
                        }
                    }
                }
                
                
                if(![videos isKindOfClass:[[NSNull null] class]])
                    [dataSource addObject:newvideo];
            }
        }
        
        [collectionSource reloadData];
    }
    else
        start = -1;
    
    if(player)
        player.dataSource = dataSource;
    
    
    // first play video...
    if(dataSource.count > 0)
        [self firstVideoLoad];
    
    User *user = [[GSUserSync sharedInstance] getSavedUser];
    if(user)
    {
        if([channelName.text rangeOfString:@"iSofa.tv Experience"].length > 0)
            [self openInitialFacebook];
    }
    
    [self closeRequest];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) loadYoutubeBest
{
    downloader = [Downloader sharedInstance];
    downloader.delegate = self;
    [downloader requestDataWithType:kRequestTypeYoutubeBest andText:nil];
}

- (void) showActivity
{
    screenLocker.labelText = @"Please wait...";
    screenLocker.hidden = NO;
}

- (void) hideActivity
{
    screenLocker.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) show:(id)sender
{
    [self performSegueWithIdentifier:@"player" sender:self];
}


#pragma mark - list
- (void) nextStep
{
    if (nextPage && [lastURL rangeOfString:SEARCH_URL].length > 0)
    {
        [self nextPageSearch];
        
    }
    else if ([lastURL rangeOfString:HISTORY_URL].length > 0 && start >= 0)
    {
        start+=10;
        [self initRequest];
        [self requestHistory:start];
    }
    else if ([lastURL rangeOfString:CHANNEL_VIDEOS_URL].length > 0 && start >= 0)
    {
        start+=10;
        [self initRequest];
        [self openChannelVideos:my_channel];
    }
    else if ([lastURL rangeOfString:FB_URL].length > 0 && start >= 0)
    {
        start+=10;
        [self nextFacebookStep];
    }
}

- (void) prevStep
{
    [pageArray removeLastObject];
    nextPage = pageArray.lastObject;
    
    if (nextPage && [lastURL rangeOfString:SEARCH_URL].length > 0)
    {
        [self nextPageSearch];
    }
    else if ([lastURL rangeOfString:HISTORY_URL].length > 0 && start >= 0)
    {
        start-=10;
        [self initRequest];
        [self requestHistory:start];
    }
    else if ([lastURL rangeOfString:CHANNEL_VIDEOS_URL].length > 0 && start >= 0)
    {
        start-=10;
        [self initRequest];
        [self openChannelVideos:my_channel];
    }
    else if ([lastURL rangeOfString:FB_URL].length > 0 && start >= 0)
    {
        start-=10;
        [self nextFacebookStep];
    }
}


#pragma mark - parser
-(void)finishParsingVideoList:(NSArray *)list
{
    [dataSource addObjectsFromArray:list];
    [collectionSource reloadData];

    [self hideActivity];
    if(player)
    {
        player.dataSource = dataSource;
    }
    
    [self firstVideoLoad];
}

-(void)firstVideoLoad
{
    if(!firstLoad)
    {
        firstLoad = YES;
        [self performSelector:@selector(loadFirstVideo) withObject:nil afterDelay:1.0f];
    }
}


- (void) resetRequest
{
    my_channel = nil;
    my_keyword = nil;
    nextPage   = nil;
    start      = 0;
    [pageArray removeAllObjects];
}


-(void)finishParsingVideos
{
    [self hideActivity];
}

#pragma mark - format
- (NSString *)dateFormatted:(NSString *)date
{
    NSString *formattedString = [[NSString stringWithFormat:@"%@", date] stringByReplacingOccurrencesOfString:@"T" withString:@""];
    if(formattedString.length == 10)
        return formattedString;
    
    formattedString = [formattedString stringByReplacingCharactersInRange:NSMakeRange(18, 5) withString:@""];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
    NSDate *newDate = [df dateFromString: formattedString];
    [df setDateFormat:@"dd/MM/yyyy"];
    NSString *dateStr = [df stringFromDate:newDate];
    
    return dateStr;
}


- (NSString *)viewsFormatted:(NSInteger)viewsCount {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:@(viewsCount)];
}

- (NSString *)durationFormatted: (int)duration
{
    int currentHours = (duration / 3600);
    int currentMinutes = ((duration / 60) - currentHours*60);
    int currentSeconds = (duration % 60);
    
    return [NSString stringWithFormat:@"%02d:%02d",currentMinutes, currentSeconds];
}

#pragma mark - player
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"player"])
    {
        player = (PlayerController *) segue.destinationViewController;// ((LandscapeNavigatior *)segue.destinationViewController).topViewController);
        if(dataSource.count > 0)
        {
            player.dataSource = dataSource;
            player.index      = index;
            player.video      = video;
        }
        
        player.delegate   = self;
    }
    else if ([segue.identifier isEqualToString:@"goSearch"])
    {
        search = (SearchViewController *)segue.destinationViewController;
        search.delegate = self;
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}


- (void) loadFirstVideo
{
    
    if (dataSource.count > 0)
    {
        index = 0;
        video = dataSource[index];
        [self performSegueWithIdentifier:@"player" sender:self];
    }
}


- (IBAction) goBack
{
     [self performSegueWithIdentifier:@"player" sender:self];
}


- (IBAction) shareOnMail
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        [picker setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        picker.mailComposeDelegate = self;
        [picker setSubject: @"Talk to us!"];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"iSofa-mail@fimdesemanapictures.com", nil];
        [picker setToRecipients:toRecipients];
        [self presentViewController:picker animated:YES completion:nil];
    }
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed – Unknown Error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}


// -------------------------------------------------------------------------------------------------------------------------------------
// Search
// -------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)showSearch
{
    if(screenLocker.hidden == NO) return;
    
    strSearchChannel = @"";
    [self performSegueWithIdentifier:@"goSearch" sender:self];
}

-(void)playerInitiatedSearch:(NSString *)keyword
{
    channelName.text = keyword;
    [self searchForKeyword:keyword];
}

// -------------------------------------------------------------------------------------------------------------------------------------
// Get Channel list
// -------------------------------------------------------------------------------------------------------------------------------------

- (void)nextStepVideo
{
    [self nextStep];
}

-(void)playerPressedPlaylist
{
    [self getChannelslist];
}

- (void) openInitialFacebook
{
    ExtrasView *extras = [ExtrasView new];
    extras.delegate    = self;
    [extras requestAccessToken];
}


- (void) requestHistory:(int) next
{
    User *user = [[GSUserSync sharedInstance] getSavedUser];
    lastURL    = [NSString stringWithFormat:@"%@?id=%d&method=get&start=%d&end=%d",HISTORY_URL,user.user_id,next,end];
    [[SMServerAPI sharedInstance] performMethod:lastURL withDelegate:self andCallback:@selector(newChannelVideos:)];
}


#pragma mark - delegate
-(void)selectChannel:(NSString *)name
{
    // select channel
    [self dispatchWithCategory:@"Main Playlist" andActionName:@"Youtube Channel" andLabel:name];
    
    if(player)
    {
        [player stopActions];
        [player dismissViewControllerAnimated:YES completion:nil];
    }
    
    [dataSource removeAllObjects];
    [self resetRequest];
    [self initRequest];
    
    if([name isEqualToString:@"History"])
    {
        // KCI removed
        //[self requestHistory:start];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *savedArray = [userDefaults objectForKey:@"myHistory"];
        if (savedArray != nil)
        {
            [self newChannelVideos:savedArray];
        }
        else
        {
            [self noResults];
        }
    }
    else if([name isEqualToString:@"Facebook"])
    {
        [self openInitialFacebook];
    }
    else  if([name isEqualToString:@"Youtube"])
    {
        [self openInitialBest];
    }
    else  if([name isEqualToString:@"iSofa.tv Experience"])
    {
        [self openInitialBest];
    }
    else
    {
        [self searchForKeyword:name];
    }
    /*else
    {
        [self openChannelVideos:name];
    }*/
    
    channelName.text = name;
    if([name isEqualToString:@"espm"])
    {
        channelName.text = [NSString stringWithFormat:@"ESPM (best tv commercials)"];
    }
}

- (void) openChannelVideos:(NSString *)name
{
     my_channel  = name;
     User *user  = [[GSUserSync sharedInstance] getSavedUser];
     lastURL     = [NSString stringWithFormat:@"%@?id=%d&start=%d&end=%d&channel=%@",CHANNEL_VIDEOS_URL,user.user_id,start,end,name];
     callback    = @selector(newChannelVideos:);
     [[SMServerAPI sharedInstance] performURL:lastURL
                                 withDelegate:self
                                  andCallback:callback];
}


#pragma mark - tracker
- (void)dispatchWithCategory:(NSString *)categoryName andActionName:(NSString *)actionName andLabel:(NSString *)labelName
{
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:categoryName
                                            action:actionName
                                             label:labelName
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

#pragma mark - collection 
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataSource.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistCell *cell = (PlaylistCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //CGRect frame = cell.frame;
    //frame.size.width = self.view.bounds.size.width/3.0 - 10;
    //frame.size.height = frame.size.width + 10;
    //cell.frame = frame;
    Video *currentVideo = [dataSource objectAtIndex:indexPath.row];
    if(currentVideo.ThumbnailLargeURL)
        [cell.video setImageWithURL:[NSURL URLWithString:currentVideo.ThumbnailLargeURL] placeholderImage:[UIImage imageNamed:@"youtube-logo.png"]];
    else if(currentVideo.ThumbnailMediumURL)
        [cell.video setImageWithURL:[NSURL URLWithString:currentVideo.ThumbnailMediumURL] placeholderImage:[UIImage imageNamed:@"youtube-logo.png"]];
    else if(currentVideo.ThumbnailSmallURL)
        [cell.video setImageWithURL:[NSURL URLWithString:currentVideo.ThumbnailSmallURL] placeholderImage:[UIImage imageNamed:@"youtube-logo.png"]];
    else if (currentVideo.image)
        [cell.video setImageWithURL:[NSURL URLWithString:currentVideo.image] placeholderImage:[UIImage imageNamed:@"youtube-logo.png"]];
    else
        cell.video.image = [UIImage imageNamed:@"youtube-logo.png"];
    
    cell.video.layer.cornerRadius = 30;
    if (currentVideo.name)
        cell.name.text =  [NSString stringWithFormat:@"%@", currentVideo.name];
    else
        cell.name.text = [NSString stringWithFormat:@"No title. Video # %d", (int)indexPath.row];//@"";
    
    if(currentVideo.userName)
        cell.user.text = currentVideo.userName;
    else
     cell.user.text = @"youtuber";
    
    [cell.avatar setImageWithURL:[NSURL URLWithString:currentVideo.userProfilePictureURL] placeholderImage:[UIImage imageNamed:@"avatar_user_placeholder"]];
    cell.avatar.layer.cornerRadius = 15;
    
    if(indexPath.row == dataSource.count - 1)
    {
        [self nextStep];
    }
        
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    strSearchChannel = @"";
    index = indexPath.row;
    video = dataSource[index];
    [self performSegueWithIdentifier:@"player" sender:self];
}


@end
