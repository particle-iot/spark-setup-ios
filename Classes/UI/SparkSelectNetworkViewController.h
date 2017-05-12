//
//  ParticleSelectNetworkViewController.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/19/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleSetupUIViewController.h"

@protocol ParticleSelectNetworkViewControllerDelegate <NSObject>

-(void)willPopBackToDeviceDiscovery;

@end

@interface ParticleSelectNetworkViewController : ParticleSetupUIViewController
@property (nonatomic, strong) NSArray *wifiList;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic) BOOL needToClaimDevice;
@property (nonatomic, weak) id <ParticleSelectNetworkViewControllerDelegate> delegate;
@end


