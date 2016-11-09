//
//  SparkUserSignupViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkUserSignupViewController.h"
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#import <OnePasswordExtension/OnePasswordExtension.h>
#else
#import "Spark-SDK.h"
#import <1PasswordExtension/OnePasswordExtension.h>
#endif
#import "SparkUserLoginViewController.h"
#import "SparkSetupWebViewController.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupMainController.h"

#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif

@interface SparkUserSignupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordVerifyTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *haveAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *createAccountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupButtonSpace;
@property (weak, nonatomic) IBOutlet SparkSetupUIButton *skipAuthButton;
@property (strong, nonatomic) UIAlertView *skipAuthAlertView;
@property (weak, nonatomic) IBOutlet UIButton *onePasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *businessAccountSwitch;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *businessAccountLabel;

@end

@implementation SparkUserSignupViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([SparkSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}


-(void)applyDesignToTextField:(UITextField *)textField {
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    textField.leftView = emptyView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyNext;
    textField.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];

}

- (IBAction)businessAccountSwitchChanged:(id)sender {
    if (self.businessAccountSwitch.on) {
        self.companyNameTextField.alpha = 1.0;
        self.companyNameTextField.userInteractionEnabled = YES;
    } else {
        self.companyNameTextField.alpha = 0.6;
        self.companyNameTextField.userInteractionEnabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add underlines to link buttons / bold to navigation buttons
//    [self makeLinkButton:self.termsButton withText:nil];
//    [self makeLinkButton:self.privacyButton withText:nil];
//    [self makeBoldButton:self.haveAccountButton withText:nil];
    
    // set brand logo
    self.logoImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.logoImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    

    [self applyDesignToTextField:self.emailTextField];
    [self applyDesignToTextField:self.passwordTextField];
    [self applyDesignToTextField:self.passwordVerifyTextField];
    
    [self applyDesignToTextField:self.firstNameTextField];
    [self applyDesignToTextField:self.lastNameTextField];
    [self applyDesignToTextField:self.companyNameTextField];
    
    
    

    
    
    if ([SparkSetupCustomization sharedInstance].productMode)
    {
        self.firstNameTextField.hidden = YES;
        self.lastNameTextField.hidden = YES;
        self.companyNameTextField.hidden = YES;
        self.businessAccountLabel.hidden = YES;
        self.businessAccountSwitch.hidden = YES;
    }

    // make sign up button be closer to verify password textfield (no activation code field)
    self.signupButtonSpace.constant = 16;
    self.skipAuthButton.hidden = !([SparkSetupCustomization sharedInstance].allowSkipAuthentication);
    
    [self.onePasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
    if (!self.onePasswordButton.hidden) {
        self.onePasswordButton.hidden = ![SparkSetupCustomization sharedInstance].allowPasswordManager;
    }

    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    if (textField == self.passwordTextField)
    {
        [self.passwordVerifyTextField becomeFirstResponder];
    }
    if (textField == self.passwordVerifyTextField)
    {
        [self signupButton:self];
    }

    return YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Auth: Sign Up screen"];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onePasswordButtonTapped:(id)sender {
    NSDictionary *newLoginDetails = @{
                                      AppExtensionTitleKey: @"Particle",
                                      AppExtensionUsernameKey: self.emailTextField.text ? : @"",
                                      AppExtensionPasswordKey: self.passwordTextField.text ? : @"",
                                      AppExtensionNotesKey: @"Saved with the Particle app",
                                      AppExtensionSectionTitleKey: @"Particle",
                                      AppExtensionFieldsKey: @{
                                              @"username" : self.emailTextField.text ? : @""
                                              // Add as many string fields as you please.
                                              }
                                      };
    
    // The password generation options are optional, but are very handy in case you have strict rules about password lengths, symbols and digits.
    NSDictionary *passwordGenerationOptions = @{
                                                // The minimum password length can be 4 or more.
                                                AppExtensionGeneratedPasswordMinLengthKey: @(8),
                                                
                                                // The maximum password length can be 50 or less.
                                                AppExtensionGeneratedPasswordMaxLengthKey: @(30),
                                                
                                                // If YES, the 1Password will guarantee that the generated password will contain at least one digit (number between 0 and 9). Passing NO will not exclude digits from the generated password.
                                                AppExtensionGeneratedPasswordRequireDigitsKey: @(YES),
                                                
                                                // If YES, the 1Password will guarantee that the generated password will contain at least one symbol (See the list bellow). Passing NO with will exclude symbols from the generated password.
                                                AppExtensionGeneratedPasswordRequireSymbolsKey: @(NO),
                                                
                                                // Here are all the symbols available in the the 1Password Password Generator:
                                                // !@#$%^&*()_-+=|[]{}'\";.,>?/~`
                                                // The string for AppExtensionGeneratedPasswordForbiddenCharactersKey should contain the symbols and characters that you wish 1Password to exclude from the generated password.
                                                AppExtensionGeneratedPasswordForbiddenCharactersKey: @"!@#$%/0lIO"
                                                };
    
    [[OnePasswordExtension sharedExtension] storeLoginForURLString:@"https://login.particle.io" loginDetails:newLoginDetails passwordGenerationOptions:passwordGenerationOptions forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
        
        if (loginDictionary.count == 0) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Failed to use 1Password App Extension to save a new Login: %@", error);
            }
            return;
        }
        
        self.emailTextField.text = loginDictionary[AppExtensionUsernameKey] ? : @"";
        self.passwordTextField.text = loginDictionary[AppExtensionPasswordKey] ? : @"";
        self.passwordVerifyTextField.text = loginDictionary[AppExtensionPasswordKey] ? : @"";
        // retrieve any additional fields that were passed in newLoginDetails dictionary
    }];
}

- (IBAction)signupButton:(id)sender
{
    [self.view endEditing:YES];
    __block NSString *email = [self.emailTextField.text lowercaseString];
    
    if (self.passwordTextField.text.length < 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password must be at least 8 characters long" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else if (![self.passwordTextField.text isEqualToString:self.passwordVerifyTextField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords do not match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self isValidEmail:email])
    {
        BOOL productMode = [SparkSetupCustomization sharedInstance].productMode;
        if (productMode)
        {
            // org user sign up
            [self.spinner startAnimating];
            self.signupButton.enabled = NO;
            
            // Sign up and then login
            [[SparkCloud sharedInstance] signupWithCustomer:email password:self.passwordTextField.text orgSlug:[SparkSetupCustomization sharedInstance].organizationSlug completion:^(NSError *error) {
                if (!error)
                {
#ifdef ANALYTICS
                    [[SEGAnalytics sharedAnalytics] track:@"Auth: Signed Up New Customer"];
#endif
                    
                    [self.delegate didFinishUserAuthentication:self loggedIn:YES];

                }
                else
                {
                    [self.spinner stopAnimating];
                    self.signupButton.enabled = YES;
                    NSLog(@"Error signing up: %@",error.localizedDescription);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not signup" message:@"Make sure your user email does not already exist and that you have entered the activation code correctly and that it was not already used"/*error.localizedDescription*/ delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
            }];
        }
        else
        {
            // normal user sign up
            [self.spinner startAnimating];
            self.signupButton.enabled = NO;
            
            NSMutableDictionary *accountInfo;
            if ((![self.firstNameTextField.text isEqualToString:@""]) || (![self.lastNameTextField.text isEqualToString:@""]) || (![self.companyNameTextField.text isEqualToString:@""])) {
                accountInfo = [@{@"firstName":self.firstNameTextField.text,
                                 @"lastName":self.lastNameTextField.text,
                                 @"businessAccount":[NSNumber numberWithBool:self.businessAccountSwitch.on],
                                 @"companyName":self.companyNameTextField.text} mutableCopy];
            }
            
            // Sign up and then login
            [[SparkCloud sharedInstance] createUser:email password:self.passwordTextField.text accountInfo:accountInfo completion:^(NSError *error) {
                if (!error)
                {
#ifdef ANALYTICS
                    [[SEGAnalytics sharedAnalytics] track:@"Auth: Signed Up New User"];
#endif
                    
                    [[SparkCloud sharedInstance] loginWithUser:email password:self.passwordTextField.text completion:^(NSError *error) {
                        [self.spinner stopAnimating];
                        self.signupButton.enabled = YES;
                        if (!error)
                        {
                            //                        [self performSegueWithIdentifier:@"discover" sender:self];
                            [self.delegate didFinishUserAuthentication:self loggedIn:YES];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                }
                else
                {
                    [self.spinner stopAnimating];
                    self.signupButton.enabled = YES;
                    NSLog(@"Error signing up: %@",error.localizedDescription);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
            }];
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)privacyPolicyButton:(id)sender
{
    [self.view endEditing:YES];
    
    SparkSetupWebViewController* webVC = [[SparkSetupMainController getSetupStoryboard]instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].privacyPolicyLinkURL;
//    webVC.htmlFilename = @"test";
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)termOfServiceButton:(id)sender
{
    [self.view endEditing:YES];
    SparkSetupWebViewController* webVC = [[SparkSetupMainController getSetupStoryboard] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].termsOfServiceLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)haveAnAccountButtonTouched:(id)sender
{
    [self.view endEditing:YES];
    [self.delegate didRequestUserLogin:self];
    
    /*
    SparkUserLoginViewController* loginVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"login"];
    loginVC.delegate = self.delegate;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;// //UIModalPresentationPageSheet;
    [self presentViewController:loginVC animated:YES completion:nil];
     */
}

- (IBAction)skipAuthButtonTapped:(id)sender {
    // that means device is claimed by somebody else - we want to check that with user (and set claimcode if user wants to change ownership)
    NSString *messageStr = [SparkSetupCustomization sharedInstance].skipAuthenticationMessage;
    self.skipAuthAlertView = [[UIAlertView alloc] initWithTitle:@"Skip authentication" message:messageStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No",nil];
    [self.skipAuthAlertView show];

}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.skipAuthAlertView)
    {
        if (buttonIndex == 0) //YES
        {
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Auth: Auth skipped"];
#endif
            [self.delegate didFinishUserAuthentication:self loggedIn:NO];
        }
    }
}


@end
