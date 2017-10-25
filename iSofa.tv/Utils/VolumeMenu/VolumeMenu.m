//
//  VolumeMenu.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "VolumeMenu.h"

@implementation VolumeMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [super awakeFromNib];
    volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    volumeView.center = CGPointMake(-1000, -1000);
    offset         = CGRectGetWidth(self.frame);
   
    
    
   
    [timeSlider setThumbImage:[UIImage imageNamed:@"volume_slider"] forState:UIControlStateNormal];
    [timeSlider setThumbImage:[UIImage imageNamed:@"volume_slider"] forState:UIControlStateHighlighted];
    timeSlider.value = [[MPMusicPlayerController applicationMusicPlayer] volume];
    timeSlider.maximumValue = 1.0f;
    timeSlider.center = CGPointZero;
    
}
#pragma mark - state

-(void)updateVisualPosition:(BOOL)hide animated:(BOOL )animated
{
    float duration = 0.5f;
    if (!animated)
        duration = 0.0f;
   
   
    if (CGPointEqualToPoint(timeSlider.center, CGPointZero))
    {
        timeSlider.frame     = CGRectMake(0, 0, 200, CGRectGetHeight(timeSlider.frame));
        timeSlider.transform = CGAffineTransformMakeRotation(- M_PI_2);
    }
    if (!hide)
    {
        [self showThis];
    }
    else
    {
        [self performSelector:@selector(hideThis) withObject:nil afterDelay:duration];
    }
    
    [UIView animateWithDuration:duration animations:^
    {

       if (!hide)
       {
           self.alpha = 1.0f;
           self.userInteractionEnabled = YES;
           
       }
       else
       {
           self.alpha = 0.0f;
           self.userInteractionEnabled = NO;
           
       }
        
    }];

    self.onScreen = hide;
    
    if (![self.superview.subviews containsObject:volumeView])
    {
        [self.superview addSubview:volumeView];
        
        
       
    }
     timeSlider.center     = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height/2 );
}
- (void) showThis
{
    self.frame = CGRectMake(CGRectZero.origin.x,
                            CGRectZero.origin.y + offset,
                            offset,
                            200
                            );
 
}
- (void) hideThis
{
    self.frame = CGRectMake(CGRectZero.origin.x - offset,
                            CGRectZero.origin.y + offset,
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame)
                            );
}

-(void)updateSliderWithCurrent:(UISlider *)slider
{
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:slider.value];
}


@end
