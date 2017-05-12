//
//  ParticleUserSignupViewController.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleSetupUIViewController.h"
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Particle-SDK.h"
#endif

@protocol ParticleUserLoginDelegate <NSObject>
@required
-(void)didFinishUserAuthentication:(id)sender loggedIn:(BOOL)loggedIn;
-(void)didRequestUserSignup:(id)sender;
-(void)didRequestUserLogin:(id)sender;
-(void)didRequestPasswordReset:(id)sender;
@end


@interface ParticleUserSignupViewController : ParticleSetupUIViewController
@property (nonatomic, strong) id<ParticleUserLoginDelegate> delegate;
@property (nonatomic, strong) NSString *predefinedActivationCode;

@end
