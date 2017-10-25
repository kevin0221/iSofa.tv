//
//  SMServerAPI.h
//  iTrack
//
//  Created by Sorin's Macbook Pro on 01/06/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define BASE_URL           @"http://api.isofa.whatihavebecome.com"          //104.236.227.47

//#define BEST_YOUTUBE_PATH  @"/youtube/best"
//#define CHANNELS_PATH      @"/youtube/channels"
//#define CHANNEL_PATH       @"/youtube/channels/#/get"


//#define CHANNELS_URL       @"http://159.203.141.118/isofatv/get_available_channel_list.php"
//#define LOCAL_URL          @""//@"http://162.243.18.93/isofatv/google_step.php?maxResults=50"
//#define LOGIN_URL          @"http://162.243.18.93/isofatv/user_management.php"


//#define SEARCH_URL         @"/youtube/search"//@"http://162.243.18.93/isofatv/content_google_search.php"
//#define FB_URL             @"http://162.243.18.93/isofatv/content_facebook.php"
//#define CHANNEL_VIDEOS_URL @""//@"http://162.243.18.93/isofatv/content_channel_grabber.php"
//#define HISTORY_URL        @"http://162.243.18.93/isofatv/content_history.php"

#define BASE_URL           @""

//#define BEST_YOUTUBE_PATH  @"http://api.isofa.whatihavebecome.com/youtube/best"
//#define SEARCH_URL  @"http://api.isofa.whatihavebecome.com/youtube/search"
#define BEST_YOUTUBE_PATH  @"http://server.isofa.tv/google_step.php"
#define SEARCH_URL         @"http://server.isofa.tv/google_search.php"
#define CHANNELS_PATH      @"http://server.isofa.tv/get_available_channel_list.php"

//#define CHANNEL_PATH       @"/youtube/channels/#/get"

#define LOGIN_URL          @"http://server.isofa.tv/user_management.php"
//#define CHANNELS_URL       @"http://162.243.18.93/isofatv/get_available_channel_list.php"
#define CHANNELS_URL       @"http://server.isofa.tv/get_available_channel_list.php"
#define FB_URL             @"http://server.isofa.tv/content_facebook.php"
#define LOCAL_URL          @""

#define CHANNEL_VIDEOS_URL @""//@"http://server.isofa.tv/content_channel_grabber.php"
#define HISTORY_URL        @"http://server.isofa.tv/content_history.php"



@interface SMServerAPI : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSMutableData *appendData;
    SEL baseCallback;
    id  baseDelegate;
}


+(SMServerAPI *)sharedInstance;
-(void) performMethod:(NSString *) method withDelegate:(id) delegate andCallback:(SEL) callback;
-(void) performMethod:(NSString *)method withParameters:(NSDictionary *)dict withDelegate:(id)delegate andCallback:(SEL)callback;
-(void) performURL:(NSString *)url withDelegate:(id)delegate andCallback:(SEL)callback;
@end
