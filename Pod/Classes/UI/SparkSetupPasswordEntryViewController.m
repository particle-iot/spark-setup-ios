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
#import "SparkSetupCommManager.h"

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

    // Hack to update cursor position to match new length of dots/chars
    NSString *tmp = self.passwordTextField.text;
    self.passwordTextField.text = @" ";
    self.passwordTextField.text = tmp;
    
}


- (IBAction)connectButtonTapped:(id)sender
{
    int minWifiPassChars = 8;
    if ([self.securityTypeLabel.text containsString:@"WEP"])
        minWifiPassChars = 5;
    
    if (self.passwordTextField.text.length < minWifiPassChars)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid password" message:[NSString stringWithFormat:@"Password must be %d characters or longer",minWifiPassChars] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self.view endEditing:YES];
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
        switch ([securityType intValue]) {
        case SparkSetupWifiSecurityTypeOpen:
            return @"Unsecured";
            break;
        case SparkSetupWifiSecurityTypeWEP_PSK:
            return @"WEP-PSK";
            break;
        case SparkSetupWifiSecurityTypeWEP_SHARED:
            return @"WEP-Shared";
            break;
        case SparkSetupWifiSecurityTypeWPA_TKIP_PSK:
            return @"WPA-TKIP";
            break;
        case SparkSetupWifiSecurityTypeWPA_AES_PSK:
            return @"WPA-AES";
            break;
        case SparkSetupWifiSecurityTypeWPA2_AES_PSK:
            return @"WPA2-AES";
            break;
        case SparkSetupWifiSecurityTypeWPA2_TKIP_PSK:
            return @"WPA2-TKIP";
            break;
        case SparkSetupWifiSecurityTypeWPA2_MIXED_PSK:
            return @"WPA2-Mixed";
            break;
            
        default:
            return @"unknown";
            break;
    }
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
