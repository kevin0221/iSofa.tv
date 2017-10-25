//
//  SearchViewController.m
//  iSofa.tv
//
//  Created by Kirt Jin on 10/13/15.
//  Copyright © 2015 Sorin's Macbook Pro. All rights reserved.
//

#import "SearchViewController.h"

@implementation SearchViewController


-(void)viewDidLayoutSubviews
{
    UIColor *color = [UIColor colorWithRed:254/255.0 green:193/255.0 blue:11/255.0 alpha:1];
    [self.txtSearch setValue: color forKeyPath:@"_placeholderLabel.textColor"];
}

-(void)viewDidLoad
{
    [self.txtSearch becomeFirstResponder];
}

// ------------------------------------------------------------------------------------------------------------------------
// Search
// ------------------------------------------------------------------------------------------------------------------------

-(IBAction)onExitSearch:(id)sender
{
    [self.txtSearch resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text isEqualToString:@""]) return false;
    
    // call search...
    if ([_delegate respondsToSelector:@selector(playerInitiatedSearch:)])
    {
        [_delegate playerInitiatedSearch:textField.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return true;
}

@end
