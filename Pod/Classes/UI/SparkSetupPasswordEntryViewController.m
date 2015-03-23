//
//  SparkSetupPasswordEntryViewController.m
//  teacup-ios-app
//
//  Created by Ido on 1/20/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkSetupPasswordEntryViewController.h"
#import "SparkSetupUILabel.h"
#import "SparkSetupCustomization.h"
#import "SparkConnectingProgressViewController.h"

@interface SparkSetupPasswordEntryViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *networkNameLabel;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *securityTypeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showPasswordSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;

@end

@implementation SparkSetupPasswordEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // move to super viewdidload?
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    
    self.passwordTextField.leftView = emptyView;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyJoin;

    self.networkNameLabel.text = self.networkName;
    self.securityTypeLabel.text = [self convertSecurityTypeToString:self.security];
    self.showPasswordSwitch.onTintColor = [SparkSetupCustomization sharedInstance].elementBackgroundColor;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPasswordSwitchTapped:(id)sender
{
    self.passwordTextField.secureTextEntry = self.showPasswordSwitch.isOn;
}


- (IBAction)connectButtonTapped:(id)sender
{
    if (self.passwordTextField.text.length < 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid password" message:@"Password must be 8 characters or longer" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:@"connect" sender:self];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"connect"])
    {
        // Get reference to the destination view controller
        SparkConnectingProgressViewController *vc = [segue destinationViewController];
        vc.networkName = self.networkName;
        vc.channel = self.channel;
        vc.security = self.security;
        vc.password = self.passwordTextField.text;
        vc.deviceID = self.deviceID; // propagate device ID
        vc.needToClaimDevice = self.needToClaimDevice; // propagate claiming
    }

}

-(NSString *)convertSecurityTypeToString:(NSNumber *)securityType
{
    return @"WPA2";
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
    {
        [self connectButtonTapped:self];
    }
    
    return YES;
}


- (IBAction)changeNetworkButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
