//
//  SparkSetupCustomization.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/12/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SparkSetupCustomization : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) UIImage *deviceImage; // resolution?

@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) UIImage *brandImage; // resolution?
@property (nonatomic, strong) UIColor *brandImageBackgroundColor;
@property (nonatomic, strong) NSString *welcomeVideoFilename;

@property (nonatomic, strong) NSString *modeButtonName;
@property (nonatomic, strong) NSString *listenModeLEDColorName;
@property (nonatomic, strong) NSString *networkNamePrefix; //photon  -<xxxxxx>

@property (nonatomic, strong) NSURL *termsOfServiceLinkURL;
@property (nonatomic, strong) NSURL *privacyPolicyLinkURL;
@property (nonatomic, strong) NSURL *forgotPasswordLinkURL;
@property (nonatomic, strong) NSURL *troubleshootingLinkURL;

@property (nonatomic, strong) NSString *termsOfServiceHTMLFile;
@property (nonatomic, strong) NSString *privacyPolicyHTMLFile;
@property (nonatomic, strong) NSString *forgotPasswordHTMLFile;
@property (nonatomic, strong) NSString *troubleshootingHTMLFile;

@property (nonatomic, strong) UIColor *pageBackgroundColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *linkTextColor;
@property (nonatomic, strong) UIColor *errorTextColor;

@property (nonatomic, strong) UIColor *elementBackgroundColor;
@property (nonatomic, strong) UIColor *elementTextColor;
@property (nonatomic, strong) NSString *normalTextFontName; // include OTF/TTF file in project
@property (nonatomic, strong) NSString *boldTextFontName; // include OTF/TTF file in project
@property (nonatomic) CGFloat fontSizeOffset; // offset of font size so small/big fonts can be displayed nicely

@property (nonatomic, assign) BOOL organization; // enable invite codes, other APIs
@property (nonatomic, strong) NSString *organizationName; // organizational name for API endpoint URL
@property (nonatomic, strong) NSString *getReadyVideoFilePath; // video in get ready screen
@property (nonatomic, strong) NSString *discoverVideoFilePath; // video in device discovery screen


@end
