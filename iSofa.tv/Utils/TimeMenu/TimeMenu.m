//
//  TimeMenu.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "TimeMenu.h"

@implementation TimeMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [self setupSlider];
}
- (void) setupSlider
{
    [self cancelTimer];
    timeSlider.maximumValue = 0;
    timeSlider.value        = 0;
     timeLabel.text         = [NSString stringWithFormat:@"%02d:%02d",0, 0];
    [timeSlider setThumbImage:[self imageFromText:[NSString stringWithFormat:@"%02d:%02d",0, 0]] forState:UIControlStateNormal];

}

-(UIImage *)imageFromText:(NSString *)text
{
    UIImage *uiimage = [UIImage imageNamed:@"bulb"];

    UIFont *font = [UIFont systemFontOfSize:13];

    if (&UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(uiimage.size,NO,0.0);
   
    [uiimage drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:0.75];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
    [text    drawAtPoint:CGPointMake(5, 13) withFont:font];
   
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma mark - set slider
- (void) cancelTimer
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }

}
- (void) startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
}
- (void) updateSlider
{
    timeSlider.value ++;
    [self updateSliderWithDuration:timeSlider.value];
}
#pragma mark - values
-(void)setCurrentValue:(CGFloat)value
{
    timeSlider.value = value;
}

-(void)setMinimumValue:(CGFloat)minValue
{
    timeSlider.minimumValue = minValue;
}

-(void)setMaximumValue:(CGFloat)maxValue
{
    timeSlider.maximumValue = maxValue;
    [self updateLabelWithDuration:maxValue];
    [self cancelTimer];
    [self startTimer];
}

#pragma mark - update Label
- (void) updateSliderWithDuration:(CGFloat) maxValue
{
    long duration = (long) maxValue;
    int currentHours   = (duration / 3600);
    int currentMinutes = ((duration / 60) - currentHours*60);
    int currentSeconds = (duration % 60);
    
    if (currentHours > 0)
    {
       [timeSlider setThumbImage:[self imageFromText:[NSString stringWithFormat:@"%02d:%02d:%02d",currentHours,currentMinutes, currentSeconds]] forState:UIControlStateNormal];
    }
    else
    {
       [timeSlider setThumbImage:[self imageFromText:[NSString stringWithFormat:@"%02d:%02d",currentMinutes, currentSeconds]] forState:UIControlStateNormal];
    }
  
}
- (void) updateLabelWithDuration:(CGFloat ) maxValue
{
    long duration = (long) maxValue;
    int currentHours   = (duration / 3600);
    int currentMinutes = ((duration / 60) - currentHours*60);
    int currentSeconds = (duration % 60);
    
    if (currentHours > 0)
    {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",currentHours,currentMinutes, currentSeconds];
    }
    else
    {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",currentMinutes, currentSeconds];
    }

}
#pragma mark - slider
-(void)updateSliderWithCurrent:(UISlider *)slider
{
    if ([_delegate respondsToSelector:@selector(timeMenuUpdateWithCurrentValue:)])
    {
        [_delegate timeMenuUpdateWithCurrentValue:slider.value];
    }
}
-(void)changeTimerState:(BOOL)on
{
    if (on)
    {
        [self cancelTimer];
        [self startTimer];
    }
    else
    {
        [self cancelTimer];
    }
}
#pragma mark - state
-(void)updateVisualPosition:(BOOL)hide animated:(BOOL )animated
{
    float duration = 0.5f;
    if (!animated) duration = 0.0f;

    
   [UIView animateWithDuration:duration animations:^{
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
}
- (void) showThis
{
    self.alpha = 0.0f;
    self.userInteractionEnabled = NO;
    self.frame = CGRectMake(CGRectZero.origin.x,
                            CGRectZero.origin.y,
                            CGRectGetWidth(self.superview.frame),
                            CGRectGetHeight(self.frame));
}
- (void) hideThis
{
    self.frame = CGRectMake(CGRectZero.origin.x ,
                            CGRectZero.origin.y - CGRectGetHeight(self.frame),
                            CGRectGetWidth(self.superview.frame),
                            CGRectGetHeight(self.frame));
}
@end
