//
//  ParticleSetupSuccessFailureViewController.h
//  teacup-ios-app
//
//  Created by Ido on 2/3/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

#import "ParticleSetupUIViewController.h"
#import "ParticleSetupMainController.h"
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Particle-SDK.h"
#endif

//@class ParticleDevice;

@interface ParticleSetupResultViewController : ParticleSetupUIViewController
@property (nonatomic, strong) ParticleDevice *device; // device instance for successful setup
@property (nonatomic, strong) NSString *deviceID; // device ID reporting for failed setup
@property (nonatomic) ParticleSetupMainControllerResult setupResult;

@end
