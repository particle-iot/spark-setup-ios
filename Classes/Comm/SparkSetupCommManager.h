//
//  ParticleSetupManager.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/20/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParticleSetupConnection.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

extern NSString *const kParticleSetupConnectionEndpointAddress;
extern int const kParticleSetupConnectionEndpointPort;

typedef NS_ENUM(NSInteger, ParticleSetupWifiSecurityType) {
    ParticleSetupWifiSecurityTypeOpen           = 0,          /**< Unsecured                               */
    ParticleSetupWifiSecurityTypeWEP_PSK        = 1,          /**< WEP Security with open authentication   */
    ParticleSetupWifiSecurityTypeWEP_SHARED     = 0x8001,     /**< WEP Security with shared authentication */
    ParticleSetupWifiSecurityTypeWPA_TKIP_PSK   = 0x00200002, /**< WPA Security with TKIP                  */
    ParticleSetupWifiSecurityTypeWPA_AES_PSK    = 0x00200004, /**< WPA Security with AES                   */
    ParticleSetupWifiSecurityTypeWPA2_AES_PSK   = 0x00400004, /**< WPA2 Security with AES                  */
    ParticleSetupWifiSecurityTypeWPA2_TKIP_PSK  = 0x00400002, /**< WPA2 Security with TKIP                 */
    ParticleSetupWifiSecurityTypeWPA2_MIXED_PSK = 0x00400006, /**< WPA2 Security with AES & TKIP           */
};


@interface ParticleSetupCommManager : NSObject

/**
 *  Check if currently connected wifi is the Soft AP device wi-fi network
 *
 *  @param networkPrefix Device Soft AP SSID prefix
 *
 *  @return YES if connected, NO otherwise
 */
+(BOOL)checkParticleDeviceWifiConnection:(NSString *)networkPrefix;

/**
 *  Use to initialize comm manager
 *
 *  @param networkPrefix Device Soft AP SSID prefix
 *
 *  @return Initialized comm manager or bil if error
 */
-(instancetype)initWithNetworkPrefix:(NSString *)networkPrefix;


-(void)version:(void(^)(id version, NSError *error))completion;
-(void)deviceID:(void(^)(id responseDict, NSError *error))completion;
-(void)scanAP:(void(^)(id scanResponse, NSError *error))completion; 
-(void)configureAP:(NSString *)ssid passcode:(NSString *)passcode security:(NSNumber *)securityType channel:(NSNumber *)channel completion:(void(^)(id responseCode, NSError *error))completion;
-(void)connectAP:(void(^)(id responseCode, NSError *error))completion;
-(void)publicKey:(void(^)(id responseCode, NSError *error))completion; // retrieve the device public key and store it in keychain
-(void)setClaimCode:(NSString *)claimCode completion:(void(^)(id responseCode, NSError *error))completion;
@end
