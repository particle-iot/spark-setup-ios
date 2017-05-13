//
//  ParticleUserForgotPasswordViewController.m
//  teacup-ios-app
//
//  Created by Ido on 2/13/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

#import "ParticleUserForgotPasswordViewController.h"
#import "ParticleSetupCustomization.h"
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Particle-SDK.h"
#endif
#import "ParticleSetupWebViewController.h"
#import "ParticleUserLoginViewController.h"
#import "ParticleSetupUIElements.h"
#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif

@interface ParticleUserForgotPasswordViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet ParticleSetupUIButton *resetPasswordButton;

@end

@implementation ParticleUserForgotPasswordViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.brandImageView.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    
    self.emailTextField.leftView = emptyView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyGo;
    self.emailTextField.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:16.0];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)resetPasswordButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    [self.spinner startAnimating];
    
    void (^passwordResetCallback)(NSError *) = ^void(NSError *error) {
        
        [self.spinner stopAnimating];
        self.resetPasswordButton.userInteractionEnabled = YES;
        
        if (!error)
        {
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Auth: Request password reset"];
#endif
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset password" message:@"Instuctions how to reset your password will be sent to the provided email address. Please check your email and continue according to instructions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset password" message:@"Could not find a user with supplied email address, please check the address supplied or create a new user via signup screen" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
    };
    
    if ([self isValidEmail:self.emailTextField.text])
    {
        self.resetPasswordButton.userInteractionEnabled = NO;
        if ([ParticleSetupCustomization sharedInstance].productMode) // TODO: fix that so it'll work for non-org too
        {
            [[ParticleCloud sharedInstance] requestPasswordResetForCustomer:self.emailTextField.text productId:[ParticleSetupCustomization sharedInstance].productId completion:passwordResetCallback];
        }
        else
        {
            [[ParticleCloud sharedInstance] requestPasswordResetForUser:self.emailTextField.text completion:passwordResetCallback];
        }
    }
    else
    {
        [self.spinner stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset password" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }


//        ParticleSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
//        webVC.link = [ParticleSetupCustomization sharedInstance].forgotPasswordLinkURL;
//        [self presentViewController:webVC animated:YES completion:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Auth: Forgot password screen"];
#endif
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self resetPasswordButtonTapped:self];
        return YES;

    }
    return NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.delegate didRequestUserLogin:self];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate didRequestUserLogin:self];
    
}
@end
