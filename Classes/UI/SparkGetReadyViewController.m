//
//  SparkGetReadyViewController.m
//  teacup-ios-app
//
//  Created by Ido on 1/15/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkGetReadyViewController.h"
#import "SparkSetupWebViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SparkCloud.h"
#import "SparkSetupMainController.h"
#import "SparkDiscoverDeviceViewController.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupResultViewController.h"
#import "SparkSetupCustomization.h"
#ifdef ANALYTICS
#import <Mixpanel.h>
#endif


@interface SparkGetReadyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;

@property (weak, nonatomic) IBOutlet UILabel *loggedInLabel;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *instructionsLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

// new claiming process
@property (nonatomic, strong) NSString *claimCode;
@property (nonatomic, strong) NSArray *claimedDevices;
@property (weak, nonatomic) IBOutlet SparkSetupUIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetupButton;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *loggedInUserLabel;

@end

@implementation SparkGetReadyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SparkSetupCustomization *custom = [SparkSetupCustomization sharedInstance];
    SparkCloud *sparkCloud = [SparkCloud sharedInstance];

    self.brandImageView.image = custom.brandImage;
    self.brandImageView.backgroundColor = custom.brandImageBackgroundColor;
    if (custom.productImage)
        self.productImageView.image = custom.productImage;

    if (sparkCloud.loggedInUsername)
        self.loggedInLabel.text = [self.loggedInLabel.text stringByAppendingString:sparkCloud.loggedInUsername];
    else
        self.loggedInLabel.text = @"";
    self.loggedInLabel.alpha = 0.85;
    self.logoutButton.titleLabel.font = [UIFont fontWithName:custom.headerTextFontName size:self.logoutButton.titleLabel.font.pointSize];
    [self.logoutButton setTitleColor:custom.normalTextColor forState:UIControlStateNormal];

    //    self.cancelSetupButton. // customize color too
    self.cancelSetupButton.titleLabel.font = [UIFont fontWithName:custom.headerTextFontName size:self.self.cancelSetupButton.titleLabel.font.pointSize];
    [self.cancelSetupButton setTitleColor:custom.normalTextColor forState:UIControlStateNormal];

    if (sparkCloud.isLoggedIn)
    {
        self.loggedInLabel.text = sparkCloud.loggedInUsername;
    }
    else
    {
        [self.logoutButton setTitle:@"Log in" forState:UIControlStateNormal];
        self.loggedInLabel.text = @"";
    }
    if (custom.disableLogOutOption) {
        self.logoutButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)cancelSetup:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidFinishNotification object:nil userInfo:@{kSparkSetupDidFinishStateKey:@(SparkSetupMainControllerResultUserCancel)}];

}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.videoViewWidth.constant = ((self.videoView.frame.size.height * 9.0)/16.0);
 
    UIUserNotificationType types = UIUserNotificationTypeAlert|UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    

    if (isiPhone4)
    {
        self.instructionsLabel.text = [NSString stringWithFormat:@"Scroll down for more instructions:\n%@",self.instructionsLabel.text];
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.25f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    

}

- (IBAction)troubleShootingButtonTapped:(id)sender
{
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"discover"])
    {
        SparkDiscoverDeviceViewController *vc = [segue destinationViewController];
        vc.claimCode = self.claimCode;
        vc.claimedDevices = self.claimedDevices;
    }
}


- (IBAction)readyButtonTapped:(id)sender
{
    [self.spinner startAnimating];
    self.readyButton.userInteractionEnabled = NO;
    
    
    
    //    [[SparkCloud sharedInstance] generateClaimCode
    void (^claimCodeCompletionBlock)(NSString *, NSArray *, NSError *) = ^void(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error) {
        //  [[SparkCloud sharedInstance] generateClaimCode:^(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error) {
        
        self.readyButton.userInteractionEnabled = YES;
        [self.spinner stopAnimating];
        
        if (!error)
        {
            self.claimCode = claimCode;
            self.claimedDevices = userClaimedDeviceIDs;
            //            NSLog(@"Got claim code: %@",self.claimCode);
            //            NSLog(@"Devices IDs owned by user: %@",self.claimedDevices);
            [self performSegueWithIdentifier:@"discover" sender:self];
            
        }
        else
        {
            if (error.code == 401)// localizedDescription containsString:@"unauthorized"])
            {
                NSString *errStr = [NSString stringWithFormat:@"Sorry, you must be logged in as a %@ customer.",[SparkSetupCustomization sharedInstance].brandName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access denied" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [[SparkCloud sharedInstance] logout];
                // call main delegate or post notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidLogoutNotification object:nil userInfo:nil];
            }
            else
            {
                NSString *errStr = [NSString stringWithFormat:@"Could not communicate with Particle cloud. Make sure your iOS device is connected to the internet and retry.\n\n(%@)",error.localizedDescription];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                errorAlertView.delegate = self;
                [errorAlertView show];
            }
        }
    };
    
    if ([SparkCloud sharedInstance].isLoggedIn)
    {
        if ([SparkSetupCustomization sharedInstance].organization)
        {
            [[SparkCloud sharedInstance] generateClaimCodeForOrganization:[SparkSetupCustomization sharedInstance].organizationSlug andProduct:[SparkSetupCustomization sharedInstance].productSlug withActivationCode:nil completion:claimCodeCompletionBlock];
        }
        else
        {
            [[SparkCloud sharedInstance] generateClaimCode:claimCodeCompletionBlock];
        }
    }
    else
    {
        // authentication skipped by user
        [self performSegueWithIdentifier:@"discover" sender:self];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] track:@"Device Setup: Get ready screen"];
#endif
}



- (IBAction)logoutButtonTouched:(id)sender
{
//    [self.checkConnectionTimer invalidate];
    [[SparkCloud sharedInstance] logout];
    // call main delegate or post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidLogoutNotification object:nil userInfo:nil];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
}



@end
