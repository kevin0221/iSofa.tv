//
//  FacebookService.h
//  youtube video link
//
//  Created by Daniel Popescu on 24/02/14.
//
//

#import <Foundation/Foundation.h>

typedef void (^FBServiceReadCompletitionBlock)(BOOL succes, NSError *error);
typedef void (^FBServicePublishCompletitionBlock)(BOOL succes, NSError *error);


@interface FacebookService : NSObject
{
    BOOL isPublishRequest;
}

+(id)sharedService;
- (NSString*)facebookAppId;

-(void)requestReadPermissions;
-(void)requestReadPermissionsWithBlock:(FBServiceReadCompletitionBlock)block;

-(void)requestPublishPermissions;
//-(void)postWithCompletitionBlock:(FBServicePublishCompletitionBlock)block;
//-(void)postWithURL:(NSURL *)URL andTitle:(NSString *)title;

-(void)clearPermissions;

-(BOOL)canMakeRequests;
-(void)postWithURL:(NSURL *)URL andTitle:(NSString *)title anDescription:(NSString *) desc andPicture:(NSURL *) picture;
@property (nonatomic, strong) FBServiceReadCompletitionBlock readBlock;
@property (nonatomic, strong) FBServicePublishCompletitionBlock publishBlock;

@end
