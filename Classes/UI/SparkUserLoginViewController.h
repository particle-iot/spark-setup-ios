//
//  ParticleUserLoginViewController.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/26/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleSetupUIViewController.h"
#import "ParticleUserSignupViewController.h"

@interface ParticleUserLoginViewController : ParticleSetupUIViewController
@property (nonatomic, strong) id<ParticleUserLoginDelegate> delegate;
@end
