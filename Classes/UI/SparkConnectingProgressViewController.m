//
//  SparkConnectiProgressViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/25/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkConnectingProgressViewController.h"
#import "SparkSetupCommManager.h"
#import "SparkSetupMainController.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupWebViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "SparkCloud.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupResultViewController.h"
#ifdef ANALYTICS
#import "Mixpanel.h"
#endif

NSInteger const kMaxRetriesDisconnectFromDevice = 10;
NSInteger const kMaxRetriesClaim = 15;
NSInteger const kMaxRetriesConfigureAP = 5;
NSInteger const kMaxRetriesConnectAP = 5;
NSInteger const kMaxRetriesReachability = 5;
NSInteger const kWaitForCloudConnectionTime = 3;

typedef NS_ENUM(NSInteger, SparkSetupConnectionProgressState) {
    SparkSetupConnectionProgressStateConfigureCredentials = 0,
    SparkSetupConnectionProgressStateConnectToWifi,
    SparkSetupConnectionProgressStateWaitForCloudConnection,
    SparkSetupConnectionProgressStateCheckInternetConnectivity,
    SparkSetupConnectionProgressStateVerifyDeviceOwnership,
    __SparkSetupConnectionProgressStateLast
};

@interface SparkConnectingProgressView : UIView
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIImageView *spinner;
@end

@implementation SparkConnectingProgressView

@end


@interface SparkConnectingProgressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (nonatomic, strong) NSMutableArray *connectionProgressTextList;
@property (weak, nonatomic) IBOutlet UILabel *deviceIsConnectingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
//@property (weak, nonatomic) IBOutlet UIButton *troubleshootingButton;
@property (strong, nonatomic) SparkDevice *device;

@property (strong, nonatomic) Reachability *hostReachability;
@property (nonatomic) BOOL hostReachable;
@property (nonatomic) BOOL apiReachable;
@property (nonatomic) NSInteger claimRetries;
@property (nonatomic) NSInteger configureRetries;
@property (nonatomic) NSInteger connectAPRetries;
@property (nonatomic) NSInteger disconnectRetries;
@property (nonatomic, strong) UIAlertView *errorAlertView;
//@property (nonatomic) BOOL connectAPsent, disconnectedFromDevice;
@property (nonatomic) SparkSetupResult setupResult;
@property (atomic) SparkSetupConnectionProgressState currentState;
@property (nonatomic, strong) SparkConnectingProgressView *currentStateView;
@property (strong, nonatomic) IBOutletCollection(SparkConnectingProgressView) NSArray *progressViews;

@property (weak, nonatomic) IBOutlet UIImageView *wifiSymbolImageView;
@end

@implementation SparkConnectingProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentState = SparkSetupConnectionProgressStateConfigureCredentials;
    
    self.ssidLabel.text = self.networkName;
    self.connectionProgressTextList = [[NSMutableArray alloc] init];
    
    // set logo
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    // force load from resource bundle
    self.wifiSymbolImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"wifi3"];
    
    self.hostReachable = NO;
    self.apiReachable = NO;
    self.hostReachability = [Reachability reachabilityWithHostName:@"api.particle.io"]; //TODO: change to https://api...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [self.hostReachability startNotifier];
    
//    self.connectAPsent = NO;
//    self.disconnectedFromDevice = NO;

    if ([SparkSetupCustomization sharedInstance].tintSetupImages)
    {
        self.wifiSymbolImageView.image = [self.wifiSymbolImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.wifiSymbolImageView.tintColor = [SparkSetupCustomization sharedInstance].normalTextColor;// elementBackgroundColor;;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    self.currentStateView = self.progressViews[self.currentState];
    self.currentStateView.hidden = NO;
    self.currentStateView.label.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];
    self.currentStateView.label.textColor = [SparkSetupCustomization sharedInstance].normalTextColor;
    [self startAnimatingSpinner:self.currentStateView.spinner];
    [self tintConnectionProgressStateSpinner];
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] timeEvent:@"Device Setup: Connecting progress screen activity"];
#endif
    
}




- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
//            NSLog(@"reachabilityChanged -- NO");
            self.hostReachable = NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
//            NSLog(@"reachabilityChanged -- YES 3G");
            self.hostReachable = YES; // we want to make sure device changed wifis
            break;
        }
        case ReachableViaWiFi:
        {
//            NSLog(@"reachabilityChanged -- YES WiFi");
            self.hostReachable = YES;
            break;
        }
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setCurrentConnectionProgressStateError:(BOOL)isError
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopAnimatingSpinner:self.currentStateView.spinner];
        NSString *stateImageName = (isError) ? @"x" : @"checkmark";
        self.currentStateView.spinner.image = [UIImage imageNamed:stateImageName inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        [self tintConnectionProgressStateSpinner];
    });
}


-(void)tintConnectionProgressStateSpinner
{
    self.currentStateView.spinner.image = [self.currentStateView.spinner.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if ([SparkSetupCustomization sharedInstance].tintSetupImages)
    {
        self.currentStateView.spinner.tintColor = [SparkSetupCustomization sharedInstance].normalTextColor;
    }
    else
    {
        self.currentStateView.spinner.tintColor = [SparkSetupCustomization sharedInstance].elementBackgroundColor;
    }

}

-(void)nextConnectionProgressState
{
    NSLog(@"nextConnectionProgressState called, current state: %ld",(long)self.currentState);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self stopAnimatingSpinner:self.currentStateView.spinner];
        self.currentStateView.spinner.image = [UIImage imageNamed:@"checkmark" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        [self tintConnectionProgressStateSpinner];
        self.currentState++;
        if (self.currentState < __SparkSetupConnectionProgressStateLast)
        {
            self.currentStateView = self.progressViews[self.currentState];
            self.currentStateView.hidden = NO;
            self.currentStateView.label.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];
            self.currentStateView.label.textColor = [SparkSetupCustomization sharedInstance].normalTextColor;
            [self tintConnectionProgressStateSpinner];
            [self startAnimatingSpinner:self.currentStateView.spinner];
        }
    });
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.configureRetries = 0;

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self configureDeviceNetworkCredentials];
    
}


-(void)finishSetupWithResult:(SparkSetupResult)result
{
    self.setupResult = result;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:@"done" sender:self];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"done"])
    {
        SparkSetupResultViewController *resultVC = segue.destinationViewController;
        resultVC.device = self.device;
        resultVC.setupResult = self.setupResult;
    }
}

-(void)configureDeviceNetworkCredentials // step 0
{
    
    // --- Configure-AP ---
    __block SparkSetupCommManager *managerForConfigure = [[SparkSetupCommManager alloc] init];
    
    [managerForConfigure configureAP:self.networkName passcode:self.password security:self.security channel:self.channel completion:^(id responseCode, NSError *error) {
        NSLog(@"configureAP sent");
        if ((error) || ([responseCode intValue]!=0))
        {
            if (self.currentState == SparkSetupConnectionProgressStateConfigureCredentials)
            {
                self.configureRetries++;
                if (self.configureRetries >= kMaxRetriesConfigureAP-1)
                {
                    [self setCurrentConnectionProgressStateError:YES];
                    [self finishSetupWithResult:SparkSetupResultFailureConfigure];
                }
                else
                {
                    [self configureDeviceNetworkCredentials];
                }
            }
        }
        else
        {
            if (self.currentState == SparkSetupConnectionProgressStateConfigureCredentials)
            {
                [self nextConnectionProgressState];
                self.connectAPRetries = 0;
                self.disconnectRetries = 0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self connectDeviceToNetwork];

                });
            }
            
        }
    }];
}




-(void)connectDeviceToNetwork // step 1
{
    // --- Connect-AP ---
    SparkSetupCommManager *managerForConnect = [[SparkSetupCommManager alloc] init];
//    self.connectAPsent = YES;
//    if (!self.disconnectedFromDevice)
    if (self.currentState == SparkSetupConnectionProgressStateConnectToWifi)
    {
        [managerForConnect connectAP:^(id responseCode, NSError *error) {
            while (([SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix]) && (self.disconnectRetries < kMaxRetriesDisconnectFromDevice))
            {
                [NSThread sleepForTimeInterval:2.0];
                self.disconnectRetries++;
            }
            
            // are we still connected to device?
            if ([SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
            {
                if (self.connectAPRetries++ >= kMaxRetriesConnectAP)
                {
                    [self setCurrentConnectionProgressStateError:YES];
                    [self finishSetupWithResult:SparkSetupResultFailureCannotDisconnectFromDevice];
                }
                else
                {
                    self.disconnectRetries = 0;
                    [self connectDeviceToNetwork]; // recursion retry sending connect-ap
                }
            }
            else
            {
                if (self.currentState == SparkSetupConnectionProgressStateConnectToWifi)
                {
                    [self nextConnectionProgressState];
                    [self waitForCloudConnection];
                }
            }
        }];
    }
    
}


-(void)waitForCloudConnection // step 2
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kWaitForCloudConnectionTime * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self nextConnectionProgressState];
        [self checkForInternetConnectivity];

    });
    

}

-(void)checkForInternetConnectivity // step 3
{
    
    // --- reachability check ---
    if (!self.hostReachable)
    {
        for (int i=0; i<kMaxRetriesReachability-1; i++)
        {
            if (![SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
            {
                [[SparkCloud sharedInstance] getDevices:^(NSArray *devices, NSError *error) {
                    if (!error)
                    {
//                        NSLog(@"getDevices completed - to wake radio up");
                        self.apiReachable = YES;
                    }
                }];
            }
            
            if ([self.hostReachability currentReachabilityStatus] != NotReachable)
            {
                self.hostReachable = YES;
                break;
            }
            else
            {
                [NSThread sleepForTimeInterval:2.0];
            }
        }
    }
    
    if ((self.hostReachable) || (self.apiReachable))
    {
        self.claimRetries = 0;
        // check that SSID disappears here and didn't come back
        if (self.needToClaimDevice)
        {
            [self nextConnectionProgressState];
            [self checkDeviceIsClaimed];
        }
        else
        {
            // finished
            [self setCurrentConnectionProgressStateError:NO];
            [self finishSetupWithResult:SparkSetupResultSuccessUnknown];
            
        }
    }
    else
    {
        [self setCurrentConnectionProgressStateError:YES];
        [self finishSetupWithResult:SparkSetupResultFailureCannotDisconnectFromDevice];
    }
    
}

-(void)checkDeviceIsClaimed // step 4
{
    // --- Claim device ---
//    [[SparkCloud sharedInstance] claimDevice:self.deviceID completion:^(NSError *error) {
    [[SparkCloud sharedInstance] getDevices:^(NSArray *devices, NSError *error) {
        BOOL deviceClaimed = NO;
        if (devices)
        {
            for (SparkDevice *device in devices)
            {
//                NSLog(@"list device ID: %@",device.id);
                if ([device.id isEqualToString:self.deviceID])
                {
                    // device now appear's in users claimed devices so it's claimed
                    deviceClaimed = YES;
                }
            }
        }
        
        if ((error) || (!deviceClaimed))
        {
            self.claimRetries++;
//            NSLog(@"Claim try %ld",(long)self.claimRetries);
            if (self.claimRetries >= kMaxRetriesClaim-1)
            {
                [self setCurrentConnectionProgressStateError:YES];
                [self finishSetupWithResult:SparkSetupResultFailureClaiming];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self checkDeviceIsClaimed]; // recursion retry
                });
                
            }
        }
        else
        {
//            NSLog(@"Claim success");
            // get the claimed device to report it back to the user
            [[SparkCloud sharedInstance] getDevice:self.deviceID completion:^(SparkDevice *device, NSError *error) {
                // --- Done ---
                if (!error)
                {
                    self.device = device;
//                    [self nextConnectionProgressState];
                  
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                      
                      int numberOfAttemptsBeforeErroring = 2;
                      __block int currentNumberOfAttempts = 0;
                      
                      void (^__block attemptToContactDevice)(void) = ^(void)
                      {
                        NSLog(@"about to call ⌚️🐶⏲ on attempt #%d", currentNumberOfAttempts);
                        [device callFunction:@"watchdogTime" withArguments:@[] completion:^(NSNumber *resultCode, NSError *error) {
                          if (error) {
                            NSLog(@"There was an error with the ⌚️🐶⏲");
                            if (currentNumberOfAttempts == numberOfAttemptsBeforeErroring)
                            {
                              self.setupResult = SparkSetupResultSuccessDeviceOffline;
                              [self performSegueWithIdentifier:@"done" sender:self];
                              attemptToContactDevice = nil;
                            } else {
                              currentNumberOfAttempts += 1;
                              attemptToContactDevice();
                            }
                          } else {
                            NSLog(@"Value of ⌚️🐶⏲ = %@", resultCode);
                            [self performSegueWithIdentifier:@"done" sender:self];
                            [SparkSetupResultViewController exitSetup:self.setupResult :self.device];
                            attemptToContactDevice = nil;
                          }
                        }];
                      };
                      
                      attemptToContactDevice();
                      
                    });
                }
                else
                {
                    [self setCurrentConnectionProgressStateError:YES];
                    [self finishSetupWithResult:SparkSetupResultFailureClaiming];
                }
            }];


        }
    }];
    
}



- (void)dealloc
{
//    NSLog(@"-- removed kReachabilityChangedNotification");
    [self.hostReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSLog(@"-- removed kReachabilityChangedNotification");
    [self.hostReachability stopNotifier];
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] track:@"Device Setup: Connecting progress screen activity"];
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


-(void)startAnimatingSpinner:(UIImageView *)spinner
{
    spinner.hidden = NO;
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    rotation.duration = 1.1; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [spinner.layer addAnimation:rotation forKey:@"Spin"];
}


-(void)stopAnimatingSpinner:(UIImageView *)spinner

{
//    spinner.hidden = YES;
    [spinner.layer removeAllAnimations];
}


@end
