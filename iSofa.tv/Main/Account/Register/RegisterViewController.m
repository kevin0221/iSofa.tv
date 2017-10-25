//
//  RegisterViewController.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 07/02/15.
//  Copyright (c) 2015 Sorin's Macbook Pro. All rights reserved.
//

#import "RegisterViewController.h"
#import "GSValidation.h"
#import "GSUserSync.h"
#import "User.h"
#import "SMServerAPI.h"
#import "MBProgressHUD.h"

@interface RegisterViewController ()
{
    IBOutlet UITextField *emailText;
    IBOutlet UITextField *passText;
    IBOutlet UITextField *nameText;
}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSString *) alertInfo
{
    GSValidation *validator = [GSValidation sharedInstance];
    
    NSMutableString *text   = [NSMutableString string];
    
    if (![validator validateEmail:emailText.text])
    {
        [text appendString:@"email \n"];
    }
    if (![validator validateInput:passText.text])
    {
        [text appendString:@"password"];
    }
    if (![validator validateInput:nameText.text])
    {
        [text appendString:@"name"];
    }
    return text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


- (BOOL) shouldContinueLogin
{
    NSString *text = [self alertInfo];
    if (text.length > 0)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iSofa.tv"
                                                        message: @"Please make sure the fields!"
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        
        [alert show];
        
        return NO;
    }
    
    return YES;
}

- (IBAction) performLogin
{
    if ([self shouldContinueLogin])
    {
        
        [self showProgress];
        NSDictionary *loginInfo = [NSDictionary dictionaryWithObjects:@[emailText.text,passText.text,nameText.text,@"register"] forKeys:@[@"email",@"password",@"name",@"method"]];
        
        [[SMServerAPI sharedInstance] performMethod:LOGIN_URL
                                     withParameters:loginInfo
                                       withDelegate:self
                                        andCallback:@selector(loginResult:)];
    }
    
}

/*
-(void) loginResult:(NSDictionary *)dict
{
    [self hideProgress];
  
    if (dict)
    {
        NSInteger code = [[dict objectForKey:@"code"] integerValue];
        if (code == 200)
        {
            User *user    = [User new];
            user.email    = emailText.text;
            user.name     = nameText.text;
            user.password = passText.text;
            user.user_id  = [[[dict objectForKey:@"data"] objectForKey:@"user_id"] intValue];
            
            [[GSUserSync sharedInstance] synchroniseUser:user];
            [self performSegueWithIdentifier:@"goPlayerlist" sender:self];
        }
        else
        {
            [self displayText:[dict objectForKey:@"message"]];
            
        }
    }
    else
    {
        [self displayText:@"Oops! Something gone wrong."];
        
    }
}*/
 
-(void) loginResult:(NSDictionary *)dict
{
    [self hideProgress];
    
    if (dict)
    {
        if ([dict objectForKey:@"user_id"])
        {
            User *user    = [User new];
            user.email    = emailText.text;
            user.name     = nameText.text;
            user.password = passText.text;
            user.user_id  = [[dict objectForKey:@"user_id"] intValue];
            
            [[GSUserSync sharedInstance] synchroniseUser:user];
            [self performSegueWithIdentifier:@"goPlayerlist" sender:self];
            return;
        }
    }
    
    [self displayText:@"Oops! Something gone wrong."];
}


- (void) displayText:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}
- (IBAction) goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - progress
- (void) showProgress
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText      = @"Please wait...";
}
-(void) hideProgress
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
@end
