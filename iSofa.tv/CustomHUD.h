//
//  CustomHUD.h
//  youtube video link
//
//  Created by Sorin's Macbook Pro on 08/08/14.
//
//

#import <UIKit/UIKit.h>

@interface CustomHUD : UIView
{
    IBOutlet UILabel *textLabel;
}
@property (nonatomic,strong) NSString *labelText;
@end
