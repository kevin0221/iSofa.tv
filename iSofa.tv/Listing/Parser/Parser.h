//
//  Parser.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 24/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//
#import <UIKit/UIKit.h>

@class Video;

@protocol ParserDelegate
@optional
//- (void) facebookParseFinished:(NSArray *)dataSource;
//- (void) parserFinishedParsingVideos:(NSArray *) source;
- (void) finishParsingVideo:(Video *) video;
- (void) finishParsingVideos;
- (void) finishParsingVideoList:(NSArray *)list;
@end


#import <Foundation/Foundation.h>
#import "Configuration.h"

@interface Parser : NSObject
{
    NSInteger count;
    NSMutableArray *dataSource;
}

+ (Parser *)sharedInstance;
- (void) parseFacebookInformation:(NSDictionary *)info;
- (void) parseYoutubeVideos:(NSArray *) info;
//- (NSString *)timeFormatted:(int)totalSeconds;
//- (NSString *)dateFormatted:(NSString *)date;

@property (nonatomic,strong) id delegate;


@end
