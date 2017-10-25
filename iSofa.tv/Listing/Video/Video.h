//
//  Video.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 24/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Video : NSObject

@property (nonatomic, assign) int       index;
@property (nonatomic, strong) NSString  *image;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *descriptions;
@property (nonatomic, assign) int       views;
@property (nonatomic, strong) NSString  *time;
@property (nonatomic, assign) int       duration;
@property (nonatomic, strong) NSString  *date;
@property (nonatomic, assign) BOOL      playURLLoaded;
@property (nonatomic, readonly) BOOL    hdVideoAvailable;
@property (nonatomic, strong) NSString  *videoID;
@property (nonatomic, strong) NSString  *loadURL;
@property (nonatomic, strong) NSString  *playURL;
@property (nonatomic, strong) NSURL     *playURLNormal;
@property (nonatomic, strong) NSURL     *playURLHD;
@property (nonatomic, assign) id        parent;
@property (nonatomic, assign) BOOL      isLoading;

@property (nonatomic, strong) NSString  *userID;
@property (nonatomic, strong) NSString  *userName;
@property (nonatomic, strong) NSString  *userProfilePictureURL;

@property (nonatomic, strong) NSDate    *expireDate;

@property (nonatomic, assign) BOOL      isFacebookVideo;
@property (nonatomic, assign) NSNumber  *skipped;
@property (nonatomic, strong) NSString  *ThumbnailSmallURL;
@property (nonatomic, strong) NSString  *ThumbnailMediumURL;
@property (nonatomic, strong) NSString  *ThumbnailLargeURL;
@property (nonatomic, strong) NSDictionary  *vid;


@end
