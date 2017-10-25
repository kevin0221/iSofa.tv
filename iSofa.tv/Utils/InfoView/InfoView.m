//
//  InfoView.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 25/11/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "InfoView.h"
#import "Video.h"
#import "UIImageView+WebCache.h"


@implementation InfoView


#pragma mark - state
-(void)hideScreen
{
    self.frame = CGRectMake(CGRectZero.origin.x ,
                            CGRectZero.origin.y - CGRectGetHeight(self.frame),
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame)
                            );
    self.onScreen = NO;
}


-(void)updateVisualPosition:(BOOL)hide animated:(BOOL )animated
{
    float duration = 0.5f;
    if (!animated) duration = 0.0f;
    
    // resize frame...
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(!hide) {
        rect.origin.y = -rect.size.height;
        self.hidden = NO;
    }
    self.frame = rect;

    
    // hide or show...
    [UIView animateWithDuration:duration animations:^{
        if (!hide)
        {
            self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            self.onScreen = YES;
        }
        else
        {
            self.frame = CGRectMake(0, -CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            [self performSelector:@selector(hideView) withObject:nil afterDelay:0.3];
        }
    }];
}


-(void)hideView
{
    self.onScreen = NO;
    self.hidden = YES;
}

-(void)updateVideo:(Video *)video
{
    currentVideo = video;
    
    if ([video.userProfilePictureURL length] > 0)
        [profilePicture setImageWithURL:[NSURL URLWithString:video.userProfilePictureURL]] ;
    
    profilePicture.layer.masksToBounds = YES;
    profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2;
    
    
    if ([video.ThumbnailMediumURL length] > 0)
        [ image setImageWithURL:[NSURL URLWithString:video.ThumbnailMediumURL]];
    else if ([video.ThumbnailSmallURL length] > 0)
        [image setImageWithURL:[NSURL URLWithString:video.ThumbnailSmallURL]];
    
    
    if ([video.name length] > 0)
    {
        name.text = video.name;
        //[self resizeFontForLabel:name maxSize:17 minSize:5 lblWidth:CGRectGetWidth(name.frame) lblHeight:CGRectGetHeight(name.frame)];
        //name.textColor = [UIColor whiteColor];
    }
    
    if (video.duration > 0)
    {
        time.text = [NSString stringWithFormat:@"Length: %@", [self durationFormatted:video.duration]];
        //time.textColor = [UIColor whiteColor];
    }
    
    if (false)
    {
        if ([video.userName length] > 0)
        {
            date.text = [NSString stringWithFormat:@"Shared by: %@", video.userName];
            //date.textColor = [UIColor whiteColor];
        }
    }
    else
    {
        if ([video.userName length] > 0)
        {
            date.text = [NSString stringWithFormat:@"Uploaded by: %@", video.userName];
            //date.textColor = [UIColor whiteColor];
        }
    }
    
    date.text = video.userName;
    
    
    if (video.views > 0)
    {
        views.text = [NSString stringWithFormat:@"Views: %@", [self viewsFormatted:video.views]];
        //views.textColor = [UIColor whiteColor];
    }
    
    if ([video.descriptions length] > 0)
    {
        description.text = video.descriptions;
        NSRange range = {0,0};
        [description scrollRangeToVisible:range];
    }
}


- (NSString *)durationFormatted: (int)duration
{
    int currentHours = (duration / 3600);
    int currentMinutes = ((duration / 60) - currentHours*60);
    int currentSeconds = (duration % 60);
    
    return [NSString stringWithFormat:@"%02d:%02d",currentMinutes, currentSeconds];
}

- (NSString *)dateFormatted:(NSDate *)_date
{
    NSString *formattedString = [[NSString stringWithFormat:@"%@", _date] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    formattedString = [formattedString stringByReplacingCharactersInRange:NSMakeRange(19, 5) withString:@""];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *newDate = [df dateFromString: formattedString];
    //[df setDateFormat:@"dd/MM/yyyy"];
    NSString *dateStr = [df stringFromDate:newDate];
    
    return dateStr;
}

- (void)resizeFontForLabel:(UILabel*)aLabel maxSize:(int)maxSize minSize:(int)minSize lblWidth: (float)lblWidth lblHeight: (float)lblHeight {
    // use font from provided label so we don't lose color, style, etc
    UIFont *font = aLabel.font;
    
    // start with maxSize and keep reducing until it doesn't clip
    for(int i = maxSize; i >= minSize; i--) {
        font = [font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(lblWidth, MAXFLOAT);
        
        //        NSString* string = [aLabel.text stringByAppendingString:@"..."];
        CGSize labelSize = [aLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:aLabel.lineBreakMode];
        
        if(labelSize.height <= lblHeight)
            break;
    }
    
    // Set the UILabel's font to the newly adjusted font.
    aLabel.font = font;
}

- (NSString *)viewsFormatted:(NSInteger)viewsCount {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:@(viewsCount)];
}

-(IBAction)onClickExit:(id)sender
{
    self.onScreen = YES;
    [self updateVisualPosition:YES animated:YES];
}


@end
