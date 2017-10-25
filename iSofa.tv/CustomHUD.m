//
//  CustomHUD.m
//  youtube video link
//
//  Created by Sorin's Macbook Pro on 08/08/14.
//
//

#import "CustomHUD.h"

@implementation CustomHUD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    textLabel.text = labelText;
}
@end
