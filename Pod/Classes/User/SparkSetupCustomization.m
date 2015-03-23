//
//  SparkSetupCustomization.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/12/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkSetupCustomization.h"

@implementation SparkSetupCustomization

+(instancetype)sharedInstance
{
    static SparkSetupCustomization *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil)
        {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
  
}



-(instancetype)init
{
    if (self = [super init])
    {
        self.deviceName = @"Spark device";
        self.deviceImage = [UIImage imageNamed:@"photon"];
        self.brandName = @"Spark";
        self.brandImage = [UIImage imageNamed:@"spark-logo"];
        self.brandImageBackgroundColor = [UIColor colorWithRed:0.79f green:0.79f blue:0.79f alpha:1.0f];
        
        self.modeButtonName = @"mode button";
        self.networkNamePrefix = @"Photon"; // Keurig
        self.listenModeLEDColorName = @"blue";
        self.organization = NO;
        
        self.privacyPolicyLinkURL = [NSURL URLWithString:@"https://www.spark.io/privacy"];
        self.termsOfServiceLinkURL = [NSURL URLWithString:@"https://www.spark.io/tos"];
        self.forgotPasswordLinkURL = [NSURL URLWithString:@"https://www.spark.io/forgot-password"];
        self.troubleshootingLinkURL = [NSURL URLWithString:@"https://community.spark.io/t/spark-core-troubleshooting-guide-spark-team/696"];
        // TODO: add default HTMLs
        
        self.normalTextColor = [UIColor blackColor];
        self.pageBackgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0f];
        self.linkTextColor = [UIColor blueColor];
        self.errorTextColor = [UIColor redColor];
        
        self.elementBackgroundColor = [UIColor colorWithRed:0.84f green:0.32f blue:0.07f alpha:1.0f];
        self.elementTextColor = [UIColor whiteColor];
        self.normalTextFontName = @"Gotham-Book"; // TODO: system font default
        self.boldTextFontName = @"Gotham-Bold"; // TODO: system font default
        
        return self;
    }
    
    return nil;
}

@end
