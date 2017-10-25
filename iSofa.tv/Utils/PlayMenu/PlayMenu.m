//
//  PlayMenu.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "PlayMenu.h"

@implementation PlayMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)showInfo:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(playMenuShareShow)])
    {
        [_delegate playMenuShareShow];
    }
}
-(void)showPlus:(UIButton *)sender
{
       if ([_delegate respondsToSelector:@selector(playMenuPlusShow:)])
    {
        [_delegate playMenuPlusShow:[self buttonStatus:sender]];
    }

}
-(void)showSearch:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(playMenuSearchShow)])
    {
        [_delegate playMenuSearchShow];
    }
 
}
-(void)showUser:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(playMenuUserShow:)])
    {
        [_delegate playMenuUserShow:[self buttonStatus:sender]];
    }

}
-(void)sendPlaylist:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(playMenuSendPlaylist)])
    {
        [_delegate playMenuSendPlaylist];
    }
 
}
-(void)prev:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(playMenuPrev)])
    {
        [_delegate playMenuPrev];
    }

}
-(void)next:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(playMenuNext)])
    {
        [_delegate playMenuNext];
    }

}
-(void)play_pause:(UIButton *)sender
{
    BOOL pause = [self buttonStatus:sender];
    
    //UIImage* image = [UIImage imageNamed:@"isofa_player_play"];
    
    if (!pause)
        [sender setImage:[UIImage imageNamed:@"isofa_player_pause"] forState:UIControlStateNormal];
    else
        [sender setImage:[UIImage imageNamed:@"isofa_player_play"] forState:UIControlStateNormal];
    
    if ([_delegate respondsToSelector:@selector(playMenuPlay:)])
    {
        [_delegate playMenuPlay:pause];
    }
}


#pragma mark - status
-(void)changeButtonState:(BOOL)pause
{
    if (pause)
    {
        _playButton.tag  = 0;
        [_playButton setImage:[UIImage imageNamed:@"isofa_player_pause"] forState:UIControlStateNormal];
    }
    else
    {
        _playButton.tag = 1;
        [_playButton setImage:[UIImage imageNamed:@"isofa_player_play"] forState:UIControlStateNormal];
    }
}

- (BOOL) buttonStatus:(UIButton *) sender
{
    BOOL show = NO;
    
    if (sender.tag == 0)
    {
        show = YES;
        sender.tag = 1;
    }
    else
    {
        show = NO;
        sender.tag = 0;
    }

    return show;
}


#pragma mark - state
-(void)updateVisualPosition:(BOOL)hide animated:(BOOL )animated
{
    float duration = 0.5f;
    if (!animated)
        duration = 0.0f;
    
    
    [UIView animateWithDuration:duration animations:^{
        if (!hide)
        {
            self.frame = CGRectMake(CGRectGetWidth(self.superview.frame)  - CGRectGetWidth(self.frame),
                                    CGRectGetHeight(self.superview.frame) - CGRectGetHeight(self.frame),
                                    CGRectGetWidth(self.frame),
                                    CGRectGetHeight(self.frame));
        }
        else
        {
            self.frame = CGRectMake(CGRectGetWidth(self.superview.frame)  - CGRectGetWidth(self.frame),
                                    CGRectGetHeight(self.superview.frame) + CGRectGetHeight(self.frame),
                                    CGRectGetWidth(self.frame),
                                    CGRectGetHeight(self.frame));
        }
        NSLog(@"SuperView.frame = %@", NSStringFromCGRect(self.superview.frame));
        NSLog(@"PlayMenu's frame = %@", NSStringFromCGRect(self.frame));
    }];
    
    self.onScreen = hide;
}


@end
