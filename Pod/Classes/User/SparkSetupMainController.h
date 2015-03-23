//
//  SparkSetupManager.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SparkSetupCustomization.h"
#import "SparkDevice.h"


typedef NS_ENUM(NSInteger, SparkSetupMainControllerResult) {
    SparkSetupMainControllerResultSuccess=1,
    SparkSetupMainControllerResultFailure,
    SparkSetupMainControllerResultUserCancel,
};

extern NSString *const kSparkSetupDidLogoutNotification;
extern NSString *const kSparkSetupDidFinishNotification;
extern NSString *const kSparkSetupDidFinishStateKey;
extern NSString *const kSparkSetupDidFinishDeviceKey;

@class SparkSetupMainController;

@protocol SparkSetupMainControllerDelegate
@required
// TODO: handle NSError reporting
- (void)sparkSetupViewController:(SparkSetupMainController *)controller didFinishWithResult:(SparkSetupMainControllerResult)result device:(SparkDevice *)device;
@end


@interface SparkSetupMainController : UIViewController// UINavigationController

// Viewcontroller displaying the modal setup UI control
@property (nonatomic, weak) id<SparkSetupMainControllerDelegate> delegate;
//@property (nonatomic, strong) SparkSetupCustomization *customization;

+ (SparkSetupMainController *)new;
-(id)init __attribute__((unavailable("Must use +new")));

-(void)showSignupWithPredefinedActivationCode:(NSString *)activationCode;

@end


