//
//  TimeMenu.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TimeMenuDelegate
@optional
- (void) timeMenuUpdateWithCurrentValue:(NSTimeInterval) timeInterval;
@end
@interface TimeMenu : UIView
{
    IBOutlet UISlider *timeSlider;
    IBOutlet UILabel  *timeLabel;
    NSTimer *timer;
}
@property (nonatomic,strong) id   delegate;
@property (nonatomic,assign) BOOL onScreen;
- (void) setupSlider;
- (void) setMinimumValue:(CGFloat) minValue;
- (void) setMaximumValue:(CGFloat) maxValue;
- (void) setCurrentValue:(CGFloat)value;
- (void) changeTimerState:(BOOL) on;

- (IBAction) updateSliderWithCurrent:(UISlider *) slider;
- (void) updateVisualPosition:(BOOL) hide animated:(BOOL )animated;
- (void) showThis;
@end
