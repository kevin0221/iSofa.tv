//
//  VolumeMenu.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface VolumeMenu : UIView
{
    IBOutlet UISlider *timeSlider;
    CGFloat offset;
    MPVolumeView *volumeView;

}
@property (nonatomic,strong) id   delegate;
@property (nonatomic,assign) BOOL onScreen;
- (IBAction) updateSliderWithCurrent:(UISlider *) slider;
- (void) updateVisualPosition:(BOOL) hide animated:(BOOL )animated;
@end
