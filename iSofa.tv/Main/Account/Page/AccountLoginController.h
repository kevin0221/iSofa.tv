//
//  AccountLoginController.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 07/02/15.
//  Copyright (c) 2015 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AccountLoginControllerDelegate
@optional
-(void) loginComplete;
@end
@interface AccountLoginController : UIViewController <UITextFieldDelegate>

@end
