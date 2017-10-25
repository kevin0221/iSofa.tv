//
//  PlaylistController.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//
#define ORIGINAL_SIZE CGSizeMake(320,300)
#import <UIKit/UIKit.h>
#import "Downloader.h"
#import "Parser.h"
#import "PlayerController.h"
#import "LandscapeNavigatior.h"
#import "ExtrasView.h"
#import <MessageUI/MessageUI.h>
#import "ChannelsView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "AppDelegate.h"

@interface ChannelsViewController : GAITrackedViewController <MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    PlayerController     *player;
    Downloader           *downloader;
    
    NSInteger             index;
    Video                *video;
    NSArray              *filteredSource;
    IBOutlet UILabel     *channelName;
    
}

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *fbAccount;

@end
