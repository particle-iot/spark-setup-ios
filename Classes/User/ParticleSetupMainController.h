//
//  ParticleSetupManager.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ParticleSetupCustomization.h"
//#ifdef FRAMEWORK
//#import <ParticleSDK/ParticleSDK.h>
//#else
//#import "Particle-SDK.h"
//#endif

typedef NS_ENUM(NSInteger, ParticleSetupMainControllerResult) {
    ParticleSetupMainControllerResultSuccess=1,
//    ParticleSetupMainControllerResultFailure,                        // DEPRECATED starting 0.5.0
    ParticleSetupMainControllerResultUserCancel,                       // User cancelled setup
    ParticleSetupMainControllerResultLoggedIn,                         // relevant to initWithAuthenticationOnly:YES only (user successfully logged in)
    ParticleSetupMainControllerResultSkippedAuth,                      // relevant to initWithAuthenticationOnly:YES only (user skipped authentication)
    ParticleSetupMainControllerResultSuccessNotClaimed,                // Setup finished successfully but device does not belong to currently logged in user so cannot be determined if it came online
    
    ParticleSetupMainControllerResultSuccessDeviceOffline,             // new 0.5.0 -- Setup finished successfully but device did not come online - might indicate a problem
    ParticleSetupMainControllerResultFailureClaiming,                  // new 0.5.0 -- setup was aborted because device claiming device timed out
    ParticleSetupMainControllerResultFailureConfigure,                 // new 0.5.0 -- Setup process couldn't send configure command to device - device Wi-fi network connection might have been dropped, running setup again after putting device back in listen mode is advised.
    ParticleSetupMainControllerResultFailureCannotDisconnectFromDevice,// new 0.5.0 -- Setup process couldn't disconnect from the device setup Wi-fi network. Usually an internal issue with the device, running setup again after putting device back in listen mode is advised.
    ParticleSetupMainControllerResultFailureLostConnectionToDevice     // new 0.5.0 -- Setup lost connection to the device Wi-Fi / dropped port before finalizing configuration process.
};

extern NSString *const kParticleSetupDidLogoutNotification;
extern NSString *const kParticleSetupDidFinishNotification;
extern NSString *const kParticleSetupDidFinishStateKey;
extern NSString *const kParticleSetupDidFinishDeviceKey;
extern NSString *const kParticleSetupDidFailDeviceIDKey;

@class ParticleSetupMainController;
@class ParticleDevice;

@protocol ParticleSetupMainControllerDelegate
@required
/**
 *  Method will be called whenever ParticleSetup wizard completes
 *
 *  @param controller Instance of main ParticleSetup viewController
 *  @param result     Result of setup completion - can be success, failure or user-cancelled.
 *  @param device     ParticleDevice instance in case the setup completed successfully and a ParticleDevice was claimed to logged in user
 */
- (void)particleSetupViewController:(ParticleSetupMainController *)controller didFinishWithResult:(ParticleSetupMainControllerResult)result device:(ParticleDevice *)device;

@optional
/**
 *  Optional delegate method that will be called whenever ParticleSetup wizard completes unsuccessfully in the following states: (new from 0.5.0)
 *  SuccessDeviceOffline, FailureClaiming, FailutreConfigure, FailureCannotDisconnectFromDevice, LostConnectionToDevice, SuccessNotClaimed
 *
 *  @param controller Instance of main ParticleSetup viewController
 *  @param deviceID   Device ID string of the device which was last tried to be setup
 */

- (void)particleSetupViewController:(ParticleSetupMainController *)controller didNotSucceeedWithDeviceID:(NSString *)deviceID;

@end


@interface ParticleSetupMainController : UIViewController

// Viewcontroller displaying the modal setup UI control
@property (nonatomic, weak) UIViewController<ParticleSetupMainControllerDelegate>* delegate;

/**
 *  Entry point for invoking Particle Soft AP setup wizard, use by calling this on your viewController:
 *  ParticleSetupMainController *setupController = [[ParticleSetupMainController alloc] init]; // or [ParticleSetupMainController new]
 *  [self presentViewController:setupController animated:YES completion:nil];
 *  If no active user session exists than this call will also authenticate user to the Particle cloud (or allow her to sign up) before the soft AP wizard will be displayed
 *
 *  @return An initialized ParticleSetupMainController instance ready to be presented.
 */
-(instancetype)init; // NS_DESIGNATED_INITIALIZER;

/**
 *  Entry point for invoking Particle Cloud authentication (login/signup/password recovery screens) only, use by calling this on your viewController:
 *  ParticleSetupMainController *setupController = [[ParticleSetupMainController alloc] initWithAuthenticationOnly];
 *  [self presentViewController:setupController animated:YES completion:nil];
 *  After user has successfully logged in or signed up, control will be return to the calling app. If an active user session already exists control will be returned immediately
 *
 *  @param yesOrNo YES will invoke Authentication wizard only, NO will invoke whole Device Setup process (will skip authentication if user session is active, same as calling -init)
 *
 *  @return An inititalized ParticleSetupMainController instance ready to be presented.
 */
-(instancetype)initWithAuthenticationOnly:(BOOL)yesOrNo;


/**
 *  Entry point for invoking Particle Cloud setup process only - used for configuring device Wi-Fi credentials without changing its ownership.
 *  If active user session exists - it'll be used and device will be claimed, otherwise no. Calling -initWithSetupOnly: method with an active user session is
 *  essentially the same as calling -init:
 *  use by calling this on your viewController:
 *  ParticleSetupMainController *setupController = [[ParticleSetupMainController alloc] initWithSetupOnly];
 *  [self presentViewController:setupController animated:YES completion:nil];
 *  After user has successfully logged in or signed up, control will be return to the calling app. If an active user session already exists control will be returned immediately
 *
 *  @param yesOrNo YES will invoke Setup wizard only, NO will invoke whole Device Setup process (will skip authentication if user session is active, same as calling -init)
 *
 *  @return An inititalized ParticleSetupMainController instance ready to be presented.
 */
-(instancetype)initWithSetupOnly:(BOOL)yesOrNo;


/**
 *  Open setup wizard in Signup screen with a pre-filled activation code from a URL scheme which was used to open the app.
 *  Deprecated since pod v0.3.0
 *
 *  @param activationCode Activation code string
 */
-(void)showSignupWithPredefinedActivationCode:(NSString *)activationCode __deprecated;

/**
 *  Get default resource bundle for Particle Soft AP setup wizard assets
 *
 *  @return Default assets resource NSBundle instance
 */
+(NSBundle *)getResourcesBundle;
+(UIStoryboard *)getSetupStoryboard;
+(UIImage *)loadImageFromResourceBundle:(NSString *)imageName;


@end


