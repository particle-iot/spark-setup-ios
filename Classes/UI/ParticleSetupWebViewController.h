//
//  ParticleSetupWebViewController.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/12/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleSetupUIViewController.h"

@interface ParticleSetupWebViewController : ParticleSetupUIViewController
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, strong) NSString *htmlFilename;
@property (nonatomic, strong) NSString *htmlFileDirectory;
@end


