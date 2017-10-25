//
//  SearchViewController.h
//  iSofa.tv
//
//  Created by Kirt Jin on 10/13/15.
//  Copyright © 2015 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchControllerDelegate
@optional
- (void) playerInitiatedSearch:(NSString *) keyword;
@end


@interface SearchViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic,strong) id   delegate;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;


-(IBAction)onExitSearch:(id)sender;


@end
