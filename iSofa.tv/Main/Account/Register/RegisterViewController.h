//
//  RegisterViewController.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 07/02/15.
//  Copyright (c) 2015 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RegisterViewControllerDelegate
@optional
-(void) registrationComplete;
@end
@interface RegisterViewController : UIViewController

@end
