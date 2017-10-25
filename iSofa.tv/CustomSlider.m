//
//  CustomSlider.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 17/06/15.
//  Copyright (c) 2015 Sorin's Macbook Pro. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    
    
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);;
}
@end
