//
//  Parser.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 24/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "Parser.h"
#import "Video.h"
#import "HCYoutubeParser.h"

#import <AVFoundation/AVFoundation.h>
static Parser *instance;
@implementation Parser



+(Parser *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[Parser alloc] init];
        
    }
    
    return instance;
}
- (instancetype)init
{
    if (self = [super init])
    {
        dataSource = [NSMutableArray new];
    }
    
    return self;
}
#pragma mark - facebook
-(void)parseFacebookInformation:(NSDictionary *)info
{
    NSLog(@"%@",info);
}
#pragma mark - youtube
- (void)parseYoutubeVideos:(NSArray *)info
{
    
    count = info.count;
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [self startParsing:info];
        
    });
    
   
}
- (void) startParsing:(NSArray *)feeds
{
    for(NSDictionary *feed in feeds)
    {
        if (feed[@"snippet"])
        {
            Video *video = [Video new];
            
            video.videoID = feed[@"id"];
            if ([video.videoID isKindOfClass:[NSDictionary class]])
            {
                video.videoID = [feed[@"id"] objectForKey:@"videoId"];
            }
            video.userID = [feed[@"snippet"] objectForKey:@"channelId"];
            video.userName = [feed[@"snippet"] objectForKey:@"channelTitle"];
            video.date = [feed[@"snippet"] objectForKey:@"publishedAt"];
            video.name = [feed[@"snippet"] objectForKey:@"title"];
            video.loadURL = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", video.videoID];
            NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:video.loadURL]];
            [HCYoutubeParser detailsForYouTubeURL:[NSURL URLWithString:video.loadURL] completeBlock:^(NSDictionary *details, NSError *error)
             {
                 NSArray *list = [[[details objectForKey:@"entry"] objectForKey:@"media$group"] objectForKey:@"media$thumbnail"];
                 if (list.count > 0)
                 {
                     NSDictionary *dict = list.firstObject;
                     video.ThumbnailLargeURL = [dict objectForKey:@"url"];
                     
                     if (list.count > 1)
                     {
                         NSDictionary *dict = list[1];
                         video.ThumbnailMediumURL = [dict objectForKey:@"url"];
                     }
                 }
                 NSDictionary *duration   = [[[details objectForKey:@"entry"] objectForKey:@"media$group"] objectForKey:@"yt$duration"];
                 NSString     *views      = [[[details objectForKey:@"entry"] objectForKey:@"yt$statistics"] objectForKey:@"viewCount"];
                 
                 video.duration         = [duration[@"seconds"] intValue];
                 //  video.time             = [self timeFormatted:[duration[@"seconds"] intValue]];
                 video.views            = [views intValue];
                 NSString     *description = [[[[details objectForKey:@"entry"] objectForKey:@"media$group"] objectForKey:@"media$description"] objectForKey:@"$t"];
                 video.descriptions      = description;
                 
                 
                 if (videos[@"hd720"])
                     video.playURLHD = [NSURL URLWithString:videos[@"hd720"]];
                 if (videos[@"small"])
                     video.playURLNormal = [NSURL URLWithString:videos[@"small"]];
                 if (!video.playURLNormal)
                     video.playURLNormal = [NSURL URLWithString:videos[@"medium"]];
                 
                 
                 
                 AVURLAsset *assetNormal = [AVURLAsset URLAssetWithURL:video.playURLNormal options:nil];
                 AVURLAsset *assetHD    = [AVURLAsset URLAssetWithURL:video.playURLHD options:nil];
                 if (assetNormal.playable && assetHD.playable)
                 {
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         [self addVideo:video];
//                     });
                      [dataSource addObject:video];
                 }
                 else if (assetNormal.playable && !assetHD.playable)
                 {
                     video.playURLHD = video.playURLNormal;
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         [self addVideo:video];
//                     });
                   //  [self performSelectorOnMainThread:@selector(addVideo:) withObject:video waitUntilDone:NO];
                      [dataSource addObject:video];
                 }
                 else if (!assetNormal.playable && assetHD.playable)
                 {
                      video.playURLNormal = video.playURLHD;
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         [self addVideo:video];
//                     });
                        [dataSource addObject:video];
                     // [self performSelectorOnMainThread:@selector(addVideo:) withObject:video waitUntilDone:NO];
                 }
                 else
                 {
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         [self errorVideo:nil];
//                     });
                     
                   //  [self performSelectorOnMainThread:@selector(errorVideo:) withObject:nil waitUntilDone:NO];
                 }
                 
                  count--;
                 
                 if (count % 5 == 0 && count != 0)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^
                                    {
                                        [self updateList];
                                    });
                 }
                 else
                     
                     if(count == 0)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^
                         {
                             [self updateList];
                        });
                     }
             }];
             
             
        }
        
    }
}
- (void) errorVideo:(Video *) video
{
    count--;
    if(count == 0)
    {
        if([_delegate respondsToSelector:@selector(finishParsingVideos)])
        {
            [_delegate finishParsingVideos];
        }
    }
}
- (void) addVideo:(Video *) video
{
    NSLog(@"%@",video.name);
    
    
    [dataSource addObject:video];
    
//    if([_delegate respondsToSelector:@selector(finishParsingVideo:)])
//    {
//        [_delegate finishParsingVideo:video];
//    }
    count --;
    
    if (count % 5 == 0 && count != 0)
    {
        [self updateList];
        
    }
    else
        
    if(count == 0)
    {
        [self updateList];
    }
}
- (void) updateList
{
    if([_delegate respondsToSelector:@selector(finishParsingVideoList:)])
    {
        [_delegate finishParsingVideoList:dataSource];
        [dataSource removeAllObjects];
    }
}
@end
