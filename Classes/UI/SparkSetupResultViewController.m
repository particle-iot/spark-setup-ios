//
//  SparkSetupSuccessFailureViewController.m
//  teacup-ios-app
//
//  Created by Ido on 2/3/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkSetupResultViewController.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupMainController.h"
#import "SparkSetupWebViewController.h"


@interface SparkSetupResultViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *shortMessageLabel;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *longMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *setupResultImageView;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;

@property (weak, nonatomic) IBOutlet SparkSetupUILabel *nameDeviceLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameDeviceTextField;
@property (strong, nonatomic) NSArray *randomDeviceNamesArray;

@end

@implementation SparkSetupResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set logo
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    self.nameDeviceLabel.hidden = YES;
    self.nameDeviceTextField.hidden = YES;

    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    
    self.nameDeviceTextField.leftView = emptyView;
    self.nameDeviceTextField.leftViewMode = UITextFieldViewModeAlways;
    self.nameDeviceTextField.delegate = self;
    self.nameDeviceTextField.returnKeyType = UIReturnKeyDone;
    self.nameDeviceTextField.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];

    // init funny random device names
    self.randomDeviceNamesArray = [NSArray arrayWithObjects:@"aardvark", @"bacon", @"badger", @"banjo", @"bobcat", @"boomer", @"captain", @"chicken", @"cowboy", @"cracker", @"cranky", @"crazy", @"dentist", @"doctor", @"dozen", @"easter", @"ferret", @"gerbil", @"hacker", @"hamster", @"hindu", @"hobo", @"hoosier", @"hunter", @"jester", @"jetpack", @"kitty", @"laser", @"lawyer", @"mighty", @"monkey", @"morphing", @"mutant", @"narwhal", @"ninja", @"normal", @"penguin", @"pirate", @"pizza", @"plumber", @"power", @"puppy", @"ranger", @"raptor", @"robot", @"scraper", @"scrapple", @"station", @"tasty", @"trochee", @"turkey", @"turtle", @"vampire", @"wombat", @"zombie", nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated
{
    [self disableKeyboardMovesViewUp];
    if (self.setupResult == SparkSetupResultSuccess)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.nameDeviceTextField becomeFirstResponder];
        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (self.setupResult) {
        case SparkSetupResultSuccess:
        {
            self.setupResultImageView.image = [UIImage imageNamed:@"success" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Setup completed successfully";
            self.longMessageLabel.text = @"Congrats! You've successfully set up your {device}.";
            
            self.nameDeviceLabel.hidden = NO;
            self.nameDeviceTextField.hidden = NO;
            NSString *randomDeviceName1 = self.randomDeviceNamesArray[arc4random_uniform((UInt32)self.randomDeviceNamesArray.count)];
            NSString *randomDeviceName2 = self.randomDeviceNamesArray[arc4random_uniform((UInt32)self.randomDeviceNamesArray.count)];
            self.nameDeviceTextField.text = [NSString stringWithFormat:@"%@_%@",randomDeviceName1,randomDeviceName2];
            break;
        }
            
        case SparkSetupResultSuccessUnknown:
        {
            self.setupResultImageView.image = [UIImage imageNamed:@"success" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Setup completed!";
            self.longMessageLabel.text = @"Setup was successful, but since you do not own this device we cannot know if the {device} has connected to the Internet. If you see the LED breathing cyan this means it worked! If not, please restart the setup process.";
            break;
        }
            
        case SparkSetupResultFailureClaiming:
        {
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Setup failed";
            // TODO: add customization point for custom troubleshoot texts
//            self.longMessageLabel.text = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials. If {device} LED is breathing cyan an internal cloud issue occured - please contact product support.";
            self.longMessageLabel.text = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials, please try setup process again.";

            break;
        }
            
        case SparkSetupResultFailureCannotDisconnectFromDevice:
        {
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Oops!";
            self.longMessageLabel.text = @"Setup process couldn't disconnect from the {device} Wi-fi network. This is an internal problem with the device, so please try running setup again after resetting your {device} and putting it back in listen mode (blinking blue LED) if needed.";
            break;
        }
            
        case SparkSetupResultFailureConfigure:
        {
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Uh oh!";
            self.longMessageLabel.text = @"Setup process couldn't disconnect from the {device} Wi-fi network. This is an internal problem with the device, so please try running setup again after resetting your {device} and putting it back in blinking blue listen mode if needed.";
            break;
        }
            
        case SparkSetupResultFailureLostConnectionToDevice:
        {
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Error!";
            self.longMessageLabel.text = @"Setup process couldn't configure the Wi-Fi credentials for your {device}, please try running setup again after resetting your {device} and putting it back in blinking blue listen mode if needed.";
            break;
        }
            
    }
    
    [self.longMessageLabel setType:@"normal"];
    
    if ([SparkSetupCustomization sharedInstance].tintSetupImages)
    {
        self.setupResultImageView.image = [self.setupResultImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.setupResultImageView.tintColor = [SparkSetupCustomization sharedInstance].normalTextColor;// elementBackgroundColor;;
    }

}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameDeviceTextField)
    {
        [self.device rename:textField.text completion:^(NSError *error) {
            [self doneButtonTapped:self];
        }];
    }
    
    return YES;
}



- (IBAction)doneButtonTapped:(id)sender
{
    
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if ((self.setupResult == SparkSetupResultSuccess) || (self.setupResult == SparkSetupResultSuccessUnknown))
    {
        userInfo[kSparkSetupDidFinishStateKey] = @(SparkSetupMainControllerResultSuccess);
        if (self.device)
            userInfo[kSparkSetupDidFinishDeviceKey] = self.device;
    }
    else
    {
        userInfo[kSparkSetupDidFinishStateKey] = @(SparkSetupMainControllerResultFailure);
    }
    
    // finish with success and provide device
    [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidFinishNotification
                                                        object:nil
                                                      userInfo:userInfo];

    
}


- (IBAction)troubleshootingButtonTouched:(id)sender
{
    
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
