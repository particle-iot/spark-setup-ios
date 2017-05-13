//
//  ParticleGetReadyViewController.m
//  teacup-ios-app
//
//  Created by Ido on 1/15/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "ParticleGetReadyViewController.h"
#import "ParticleSetupWebViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Particle-SDK.h"
#endif
#import "ParticleSetupMainController.h"
#import "ParticleDiscoverDeviceViewController.h"
#import "ParticleSetupUIElements.h"
#import "ParticleSetupResultViewController.h"
#import "ParticleSetupCustomization.h"
#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif


@interface ParticleGetReadyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;

@property (weak, nonatomic) IBOutlet UILabel *loggedInLabel;
@property (weak, nonatomic) IBOutlet ParticleSetupUILabel *instructionsLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

// new claiming process
@property (nonatomic, strong) NSString *claimCode;
@property (nonatomic, strong) NSArray *claimedDevices;
@property (weak, nonatomic) IBOutlet ParticleSetupUIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetupButton;
@property (weak, nonatomic) IBOutlet ParticleSetupUILabel *loggedInUserLabel;

@end

@implementation ParticleGetReadyViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.brandImageView.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    UIColor *navBarButtonsColor = ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? [UIColor whiteColor] : [UIColor blackColor];
    [self.cancelSetupButton setTitleColor:navBarButtonsColor forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:navBarButtonsColor forState:UIControlStateNormal];
    
    if ([ParticleSetupCustomization sharedInstance].productImage)
        self.productImageView.image = [ParticleSetupCustomization sharedInstance].productImage;

    if ([ParticleCloud sharedInstance].loggedInUsername)
        self.loggedInLabel.text = [self.loggedInLabel.text stringByAppendingString:[ParticleCloud sharedInstance].loggedInUsername];
    else
        self.loggedInLabel.text = @"";
    self.loggedInLabel.alpha = 0.85;
    self.logoutButton.titleLabel.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.logoutButton.titleLabel.font.pointSize];
//    [self.logoutButton setTitleColor:[ParticleSetupCustomization sharedInstance].normalTextColor forState:UIControlStateNormal];

    //    self.cancelSetupButton. // customize color too
    self.cancelSetupButton.titleLabel.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.self.cancelSetupButton.titleLabel.font.pointSize];
//    [self.cancelSetupButton setTitleColor:[ParticleSetupCustomization sharedInstance].normalTextColor forState:UIControlStateNormal];

    if ([ParticleCloud sharedInstance].isAuthenticated)
    {
        self.loggedInLabel.text = [ParticleCloud sharedInstance].loggedInUsername;
    }
    else
    {
        [self.logoutButton setTitle:@"Log in" forState:UIControlStateNormal];
        self.loggedInLabel.text = @"";
    }
    if ([ParticleSetupCustomization sharedInstance].disableLogOutOption) {
        self.logoutButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)cancelSetup:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidFinishNotification object:nil userInfo:@{kParticleSetupDidFinishStateKey:@(ParticleSetupMainControllerResultUserCancel)}];

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
    ParticleSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [ParticleSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"discover"])
    {
        ParticleDiscoverDeviceViewController *vc = [segue destinationViewController];
        vc.claimCode = self.claimCode;
        vc.claimedDevices = self.claimedDevices;
    }
}


- (IBAction)readyButtonTapped:(id)sender
{
    [self.spinner startAnimating];
    self.readyButton.userInteractionEnabled = NO;
    
    
    
    //    [[ParticleCloud sharedInstance] generateClaimCode
    void (^claimCodeCompletionBlock)(NSString *, NSArray *, NSError *) = ^void(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error) {
        //  [[ParticleCloud sharedInstance] generateClaimCode:^(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error) {
        
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
                NSString *errStr = [NSString stringWithFormat:@"Sorry, you must be logged in as a %@ customer.",[ParticleSetupCustomization sharedInstance].brandName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access denied" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [[ParticleCloud sharedInstance] logout];
                // call main delegate or post notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidLogoutNotification object:nil userInfo:nil];
            }
            else
            {
                NSString *errStr;
                if ([ParticleSetupCustomization sharedInstance].productMode) {
                    errStr = [NSString stringWithFormat:@"Could not communicate with Particle cloud. Are you sure your organization and product slugs are setup correctly?\n\n%@",error.localizedDescription];
                } else {
                    errStr = [NSString stringWithFormat:@"Could not communicate with Particle cloud. Make sure your iOS device is connected to the internet and retry.\n\n%@",error.localizedDescription];
                }
                
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                errorAlertView.delegate = self;
                [errorAlertView show];
            }
        }
    };
    
    if ([ParticleCloud sharedInstance].isAuthenticated)
    {
        if ([ParticleSetupCustomization sharedInstance].productMode)
        {
            [[ParticleCloud sharedInstance] generateClaimCodeForProduct:[ParticleSetupCustomization sharedInstance].productId completion:claimCodeCompletionBlock];
        }
        else
        {
            [[ParticleCloud sharedInstance] generateClaimCode:claimCodeCompletionBlock];
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
    [[SEGAnalytics sharedAnalytics] track:@"Device Setup: Get ready screen"];
//    NSLog(@"analytics enabled");
#endif
}



- (IBAction)logoutButtonTouched:(id)sender
{
//    [self.checkConnectionTimer invalidate];
    [[ParticleCloud sharedInstance] logout];
    // call main delegate or post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidLogoutNotification object:nil userInfo:nil];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
}



@end
