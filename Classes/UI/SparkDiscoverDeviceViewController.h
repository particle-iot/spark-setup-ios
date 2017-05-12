//
//  ParticleDiscoverDeviceViewController.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/16/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleSetupUIViewController.h"
#import "ParticleSetupMainController.h"

@interface ParticleDiscoverDeviceViewController : ParticleSetupUIViewController
@property (nonatomic, strong) NSString *claimCode;
@property (nonatomic, strong) NSArray *claimedDevices;

@end
