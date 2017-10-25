//
//  PlayMenu.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@protocol PlayMenuDelegate

@optional
- (void) playMenuInfoShow:(BOOL) show;
- (void) playMenuUserShow:(BOOL) show;
- (void) playMenuPlusShow:(BOOL) show;

- (void) playMenuSearchShow;
- (void) playMenuShareShow;
- (void) playMenuSendPlaylist;

- (void) playMenuPrev;
- (void) playMenuNext;

- (void) playMenuPlay:(BOOL) pause;
@end


@interface PlayMenu : UIView
{
}
@property (nonatomic,strong) IBOutlet UIButton *playButton;
@property (nonatomic,strong) IBOutlet id   delegate;
@property (nonatomic,assign) BOOL onScreen;
- (IBAction) showInfo:(UIButton *)sender;
- (IBAction) showUser:(UIButton *)sender;
- (IBAction) showPlus:(UIButton *)sender;
- (IBAction) showSearch:(UIButton *)sender;

- (IBAction) sendPlaylist:(UIButton *)sender;

- (IBAction) prev:(UIButton *)sender;
- (IBAction) play_pause:(UIButton *)sender;
- (IBAction) next:(UIButton *)sender;

- (void) changeButtonState:(BOOL) pause;
- (void) updateVisualPosition:(BOOL)hide animated:(BOOL )animated;
@end
