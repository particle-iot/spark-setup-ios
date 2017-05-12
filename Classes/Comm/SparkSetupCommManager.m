//
//  ParticleSetupManager.m
//  spark-setup-ios
//
//  Created by Ido Kleinman on 11/20/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//  This class implements the Particle Soft-AP protocol specified in
//  https://github.com/spark/photon-wiced/blob/master/soft-ap.md
//

#import "ParticleSetupCommManager.h"
#import "ParticleSetupConnection.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ParticleSetupSecurityManager.h"
#import <NetworkExtension/NetworkExtension.h>
//#import "FastSocket.h"

// new iOS 9 requirements:
#import "Reachability.h"
@import UIKit;


#define ENCRYPT_PWD     1

typedef NS_ENUM(NSInteger, ParticleSetupCommandType) {
    ParticleSetupCommandTypeNone=0,
    ParticleSetupCommandTypeVersion=1,
    ParticleSetupCommandTypeDeviceID=2,
    ParticleSetupCommandTypeScanAP=3,
    ParticleSetupCommandTypeConfigureAP=4,
    ParticleSetupCommandTypeConnectAP=5,
    ParticleSetupCommandTypePublicKey,
    ParticleSetupCommandTypeSet,
};


NSString *const kParticleSetupConnectionEndpointAddress = @"192.168.0.1";
NSString *const kParticleSetupConnectionEndpointPortString = @"5609";
int const kParticleSetupConnectionEndpointAddressHex = 0xC0A80001;
int const kParticleSetupConnectionEndpointPort = 5609;


@interface ParticleSetupCommManager() <ParticleSetupConnectionDelegate>

@property (nonatomic, strong) ParticleSetupConnection *connection;
@property (atomic) ParticleSetupCommandType commandType; // last command type
@property (copy)void (^commandCompletionBlock)(id, NSError *); // completion block for last sent command
//@property (copy)void (^commandDeviceIDCompletionBlock)(id, BOOL, NSError *); // completion block for commandID command

@property (copy)void (^commandSendBlock)(void); // code block for sending the command to socket
@property (nonatomic, strong) NSTimer *sendCommandTimeoutTimer;
@property (nonatomic, strong) NSString *networkNamePrefix;
@end


@implementation ParticleSetupCommManager


//-(instancetype)initWithConnection:(ParticleSetupConnection *)connection
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.commandType = ParticleSetupCommandTypeNone;
        self.commandCompletionBlock = nil;
        self.commandSendBlock = nil;
        //        self.ready = NO;
//        NSLog(@"ParticleSetupCommManager %@ instanciated!",self);
        
        return self;
        
    }
    
    return nil;
}


-(instancetype)initWithNetworkPrefix:(NSString *)networkPrefix
{
    ParticleSetupCommManager *manager = [self init];
    if (manager)
    {
        manager.networkNamePrefix = networkPrefix;
        return manager;
    }
    else
        return nil;
}

#pragma mark Particle photon device wifi connection detection methods

+(BOOL)checkParticleDeviceWifiConnection:(NSString *)networkPrefix
{
    // starting iOS 9: just try to open socket to photon - networkPrefix is ignored
    /*
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0"))
    {
        static BOOL bOpeningSocket = NO;
        
        if (bOpeningSocket)
            return NO;
        
        
        bOpeningSocket = YES;
        FastSocket *socket = [[FastSocket alloc] initWithHost:kParticleSetupConnectionEndpointAddress andPort:kParticleSetupConnectionEndpointPortString];
        
        if ([socket connect])
        {
            [socket close];
            bOpeningSocket = NO;
            return YES;
        }
        else
        {
            bOpeningSocket = NO;
            return NO;
        }
    }
    else*/
//    {
    
        // for iOS 8:
        NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
        //    NSLog(@"Supported interfaces: %@", ifs);
        NSDictionary *info;
        for (NSString *ifnam in ifs) {
            info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            //        NSLog(@"%@ => %@", ifnam, info);
            if (info && [info count]) { break; }
        }
        
        NSString *SSID = info[@"SSID"];
        //    NSLog(@"currently connected SSID: %@",SSID);
        //    if ([SSID hasPrefix:[ParticleSetupCustomization sharedInstance].networkNamePrefix])
        if ([SSID hasPrefix:networkPrefix])
        {
            return YES;
            // TODO: add notification or delegate method
            // TODO: add reachability change detection
            
        }
//    }
    
    return NO;
    
}

#pragma mark ParticleSetupConnection delegate methods

-(void)ParticleSetupConnection:(ParticleSetupConnection *)connection didReceiveData:(NSString *)data
{
    if (connection == self.connection)
    {
        NSNumber *responseCode;
        NSError *e = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&e];
        if ((!e) && (self.commandCompletionBlock))
        {
            switch (self.commandType) {
                case ParticleSetupCommandTypeVersion:
                    self.commandCompletionBlock(response[@"v"],nil); // the version string
                    //                    self.commandType = ParticleSetupCommandTypeNone;
                    break;
                    
                case ParticleSetupCommandTypeDeviceID:
                    if (self.commandCompletionBlock) // special completion
                    self.commandCompletionBlock(response, nil); // the device ID string + claimed flag dictionary
                    //                    self.commandType = ParticleSetupCommandTypeNone;
                    break;
                    
                case ParticleSetupCommandTypeScanAP:
                    self.commandCompletionBlock(response[@"scans"],nil); // the scan response array
                    //                    self.commandType = ParticleSetupCommandTypeNone;
                    break;
                    
                    
                case ParticleSetupCommandTypeConfigureAP:
                case ParticleSetupCommandTypeConnectAP:
                case ParticleSetupCommandTypeSet:
                    self.commandCompletionBlock(response[@"r"],nil); // the response code number
                    //                    self.commandType = ParticleSetupCommandTypeNone;
                    break;
                    
                case ParticleSetupCommandTypePublicKey:
                    // handle key storage
//                    NSLog(@"ParticleSetupCommandTypePublicKey response is:\n%@",response);
                    
                    responseCode = (NSNumber *)response[@"r"];
                    if (responseCode.intValue != 0)
                    {
                        self.commandCompletionBlock(nil,[NSError errorWithDomain:@"ParticleSetupCommManagerError" code:2006 userInfo:@{NSLocalizedDescriptionKey:@"Could not retrieve public key from device"}]);
                    }
                    else
                    {
                        // decode HEX encoded key to NSData
                        NSString *pubKeyHexCoded = (NSString *)response[@"b"];
//                        NSLog(@"Encoded key is %@", pubKeyHexCoded);
                        
                        NSData *pubKey = [ParticleSetupSecurityManager decodeDataFromHexString:pubKeyHexCoded];
//                        NSLog(@"Decoded key is %@", [pubKey description]);
                        
                        if ([ParticleSetupSecurityManager setPublicKey:pubKey])
                        {
//                            NSLog(@"Public key stored in keychain successfully");
                            self.commandCompletionBlock(response[@"r"],nil);
                        }
                        else
                        {
                            self.commandCompletionBlock(nil,[NSError errorWithDomain:@"ParticleSetupSecurityManager" code:2007 userInfo:@{NSLocalizedDescriptionKey:@"Could not store public key in device keychain"}]);
                        }

                    }
                default: // something else happened
                    //                    self.commandType = ParticleSetupCommandTypeNone;
                    break;
            }
            
        }
    }
    
}





-(void)ParticleSetupConnection:(ParticleSetupConnection *)connection didUpdateState:(ParticleSetupConnectionState)state error:(NSError *)error
{
    if (error)
    {
        [self.sendCommandTimeoutTimer invalidate];
        if (self.commandCompletionBlock)
            self.commandCompletionBlock(nil, [NSError errorWithDomain:@"ParticleSetupCommManagerError" code:2002 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}]);
//        self.commandCompletionBlock = nil;
        return;
    }
    
    switch (state) {
        case ParticleSetupConnectionStateClosed:
//            NSLog(@"Connection to spark device closed");
            [self.sendCommandTimeoutTimer invalidate];
            break;
            
        case ParticleSetupConnectionOpenTimeout:
//            NSLog(@"Opening connection to spark device timed out");
            [self.sendCommandTimeoutTimer invalidate];
            if (self.commandCompletionBlock)
            {
                self.commandCompletionBlock(nil, [NSError errorWithDomain:@"ParticleSetupCommManagerError" code:2002 userInfo:@{NSLocalizedDescriptionKey:@"Opening connection to spark device timed out"}]);
                self.commandCompletionBlock = nil;
            }
            break;
            
        case ParticleSetupConnectionStateOpened:
//            NSLog(@"Connection to spark device opened");
            if (self.commandSendBlock)
            {
                self.sendCommandTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(sendCommandTimeoutHandler:) userInfo:nil repeats:NO];
                self.commandSendBlock();
//                NSLog(@"Command %ld sent to spark device",(long)self.commandType);
            }
            break;
        case ParticleSetupConnectionStateError:
        case ParticleSetupConnectionStateUnknown:
            self.commandType = ParticleSetupCommandTypeNone;
            [self.sendCommandTimeoutTimer invalidate];
//            NSLog(@"Connection to spark device failed");
            if (self.commandCompletionBlock)
            {
                self.commandCompletionBlock(nil, [NSError errorWithDomain:@"ParticleSetupCommManagerError" code:2002 userInfo:@{NSLocalizedDescriptionKey:@"Connection to spark device failed"}]);
                self.commandCompletionBlock = nil;
            }
            break;
            
        default:
            break;
    }
}

/*
 -(void)writeCommandTimeoutHandler:(id)sender
 {
 self.commandType = ParticleSetupCommandTypeNone;
 //    self.connection = nil;
 
 if (self.commandCompletionBlock)
 self.commandCompletionBlock(nil,[NSError errorWithDomain:@"ParticleSetupCommManagerError" code:2002 userInfo:@{NSLocalizedDescriptionKey:@"Timeout occured while writing data to socket connection"}]);
 
 //    self.commandCompletionBlock = nil;
 }
 */



-(void)sendCommandTimeoutHandler:(id)sender
{
    
    [self.sendCommandTimeoutTimer invalidate];
    //    self.commandType = ParticleSetupCommandTypeNone;
    
    if (self.commandCompletionBlock)
        self.commandCompletionBlock(nil,[NSError errorWithDomain:@"ParticleSetupCommManagerError" code:2004 userInfo:@{NSLocalizedDescriptionKey:@"Timeout occured while waiting for response from socket"}]);
    
    self.commandCompletionBlock = nil;
}

#pragma mark TCP Socket photon soft AP protocol implementation


-(void)openConnection // and then send command (+ timeout)
{
    // TODO: add command queue
    self.connection = [[ParticleSetupConnection alloc] initWithIPAddress:kParticleSetupConnectionEndpointAddress port:kParticleSetupConnectionEndpointPort];
    self.connection.delegate = self;
}


-(BOOL)canSendCommandCallCompletionForError:(void(^)(id obj, NSError *error))completion
{
    if (self.networkNamePrefix)
    {
        if (![ParticleSetupCommManager checkParticleDeviceWifiConnection:self.networkNamePrefix])
        {
            completion(nil, [NSError errorWithDomain:@"ParticleSetupCommManangerError" code:2003 userInfo:@{NSLocalizedDescriptionKey:@"Not connected to Particle device"}]);
            return NO;
        }
    }
    
    if (self.commandType != ParticleSetupCommandTypeNone)
    {
        completion(nil, [NSError errorWithDomain:@"ParticleSetupCommManangerError" code:2005 userInfo:@{NSLocalizedDescriptionKey:@"Use a new instance of ParticleSetupCommManager per command"}]);
        return NO;
    }
    
    return YES;
}

-(void)version:(void(^)(id version, NSError *error))completion
{
    // TODO: new prototype:
    // open connection --> add semaphore to delegate
    // wait on semaphore with timeout (open socket timeout call completion)
    // do write command (+ handle completion)
    // add semaphore to receive data with timeout
    // if fails - receive data timeout
    // else calls completion with data
    // no need for NSTimers
    
    if ([self canSendCommandCallCompletionForError:completion])
    {
        __weak ParticleSetupCommManager *weakSelf = self;
        self.commandCompletionBlock = completion;
        
        self.commandSendBlock = ^{
            
            NSString *commandStr = @"version\n0\n\n";
            weakSelf.commandType = ParticleSetupCommandTypeVersion;
            [weakSelf.connection writeString:commandStr completion:^(NSError *error) {
                if ((error) && (completion))
                {
                    completion(nil, error);
                    weakSelf.commandCompletionBlock = nil;
                    //                weakSelf.commandType = ParticleSetupCommandTypeNone;
                }
            }];
        };
        // start process
        [self openConnection];
    }
    
    
}



-(void)deviceID:(void (^)(id, NSError *))completion
{
    if ([self canSendCommandCallCompletionForError:completion])
    {
        __weak ParticleSetupCommManager *weakSelf = self;
        self.commandCompletionBlock = completion;
        
        self.commandSendBlock = ^{
            
            if (weakSelf.connection.state == ParticleSetupConnectionStateOpened)
            {
                weakSelf.commandType = ParticleSetupCommandTypeDeviceID;
                NSString *commandStr = @"device-id\n0\n\n";
                
                [weakSelf.connection writeString:commandStr completion:^(NSError *error) {
                    if ((error) && (completion))
                    {
                        completion(nil, error);
                        weakSelf.commandCompletionBlock = nil;
                        //                    weakSelf.commandType = ParticleSetupCommandTypeNone;
                        
                    }
                }];
            }
            
        };
        
        [self openConnection];
    }
}



-(void)scanAP:(void(^)(id scanResponse, NSError *error))completion //NSDictionary
{
    if ([self canSendCommandCallCompletionForError:completion])
    {
        __weak ParticleSetupCommManager *weakSelf = self;
        self.commandCompletionBlock = completion;
        
        self.commandSendBlock = ^{
            
            weakSelf.commandType = ParticleSetupCommandTypeScanAP;
            NSString *commandStr = @"scan-ap\n0\n\n";
            
            [weakSelf.connection writeString:commandStr completion:^(NSError *error) {
                if ((error) && (completion))
                {
                    completion(nil, error);
                    weakSelf.commandCompletionBlock = nil;
                    //                weakSelf.commandType = ParticleSetupCommandTypeNone;
                }
            }];
            
        };
        
        [self openConnection];
        
    }
}




-(void)configureAP:(NSString *)ssid passcode:(NSString *)passcode security:(NSNumber *)securityType channel:(NSNumber *)channel completion:(void(^)(id responseCode, NSError *error))completion
{
    if ([self canSendCommandCallCompletionForError:completion])
    {
        __weak ParticleSetupCommManager *weakSelf = self;
        self.commandCompletionBlock = completion;
        
        self.commandSendBlock = ^{

            NSDictionary* requestDataDict;

            // Truncate passcode to 64 chars maximum
            NSRange stringRange = {0, MIN(passcode.length, 64)};
            // adjust the range to include dependent chars
            stringRange = [passcode rangeOfComposedCharacterSequencesForRange:stringRange];
            // Now you can create the short string
            NSString *passcodeTruncated = [passcode substringWithRange:stringRange];
            NSString *hexEncodedEncryptedPasscodeStr;
            
            if (ENCRYPT_PWD)
            {
                SecKeyRef pubKey = [ParticleSetupSecurityManager getPublicKey];
                if (pubKey != NULL)
                {
                    // encrypt it using the stored public key
                    NSData *plainTextData = [passcodeTruncated dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *cipherTextData = [ParticleSetupSecurityManager encryptWithPublicKey:pubKey plainText:plainTextData];
                    if (cipherTextData != nil)
                    {
                        // encode the encrypted data to a hex string
                        hexEncodedEncryptedPasscodeStr = [ParticleSetupSecurityManager encodeDataToHexString:cipherTextData];
//                        NSLog(@"plaintext: %@\nCiphertext:\n%@",passcodeTruncated,hexEncodedEncryptedPasscodeStr);
                        requestDataDict = @{@"idx":@0, @"ssid":ssid, @"pwd":hexEncodedEncryptedPasscodeStr, @"sec":securityType, @"ch":channel};
                    }
                    else
                    {
                        completion(nil, [NSError errorWithDomain:@"ParticleSetupSecurityManager" code:2007 userInfo:@{NSLocalizedDescriptionKey:@"Failed to encrypt passcode"}]);
                        return; //?
                    }
                }
                else
                {
                    completion(nil, [NSError errorWithDomain:@"ParticleSetupSecurityManager" code:2008 userInfo:@{NSLocalizedDescriptionKey:@"Failed to retrieve device public key from keychain"}]);
                    return; //?
                }
            }
            else
            {
                // no passcode encryption // TODO: remove when encryption functional
                requestDataDict = @{@"idx":@0, @"ssid":ssid, @"pwd":passcodeTruncated, @"sec":securityType, @"ch":channel};
            }
            
            NSError *error;
            NSString *jsonString;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDataDict
                                                               options:0
                                                                 error:&error];
            
            if (jsonData)
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            else
                completion(nil, [NSError errorWithDomain:@"ParticleSetupCommManangerError" code:2002 userInfo:@{NSLocalizedDescriptionKey:@"Cannot process configureAP command data to JSON"}]);
            
            NSString *commandStr = [NSString stringWithFormat:@"configure-ap\n%ld\n\n%@",(unsigned long)jsonString.length, jsonString];
            weakSelf.commandType = ParticleSetupCommandTypeConfigureAP;
            [weakSelf.connection writeString:commandStr completion:^(NSError *error) {
                if ((error) && (completion))
                {
                    completion(nil, error);
                    weakSelf.commandCompletionBlock = nil;
                    //                weakSelf.commandType = ParticleSetupCommandTypeNone;
                }
            }];
            
        };
        
        [self openConnection];
    }
    
}




-(void)setClaimCode:(NSString *)claimCode completion:(void (^)(id, NSError *))completion
{
    if ([self canSendCommandCallCompletionForError:completion])
    {
        __weak ParticleSetupCommManager *weakSelf = self;
        self.commandCompletionBlock = completion;
        
        self.commandSendBlock = ^{
            
            NSDictionary* requestDataDict;
            requestDataDict = @{@"k":@"cc",
                                @"v": claimCode};
            
            NSError *error;
            NSString *jsonString;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDataDict
                                                               options:0
                                                                 error:&error];
            
            if (jsonData)
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            else
                completion(nil, [NSError errorWithDomain:@"ParticleSetupCommManangerError" code:2002 userInfo:@{NSLocalizedDescriptionKey:@"Cannot process setClaimCode command data to JSON"}]);
            
            // remove backslahes that might occur from '/' in
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                          
            NSString *commandStr = [NSString stringWithFormat:@"set\n%ld\n\n%@",(unsigned long)jsonString.length, jsonString];
            weakSelf.commandType = ParticleSetupCommandTypeSet;
            [weakSelf.connection writeString:commandStr completion:^(NSError *error) {
                if ((error) && (completion))
                {
                    completion(nil, error);
                    weakSelf.commandCompletionBlock = nil;
                }
            }];
            
        };
        
        [self openConnection];
    }
}

-(void)connectAP:(void(^)(id responseCode, NSError *error))completion
{
    if ([self canSendCommandCallCompletionForError:completion])
    {
        __weak ParticleSetupCommManager *weakSelf = self;
        self.commandCompletionBlock = completion;
        
        self.commandSendBlock = ^{
            
            NSDictionary* requestDataDict = @{@"idx":@0};
            NSError *error;
            NSString *jsonString;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDataDict
                                                               options:0
                                                                 error:&error];
            
            if (jsonData)
            {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NSString *commandStr = [NSString stringWithFormat:@"connect-ap\n%ld\n\n%@",(unsigned long)jsonString.length, jsonString];
                weakSelf.commandType = ParticleSetupCommandTypeConnectAP;
                [weakSelf.connection writeString:commandStr completion:^(NSError *error) {
                    if ((error) && (completion))
                    {
                        completion(nil, error);
                        weakSelf.commandCompletionBlock = nil;
                        //                weakSelf.commandType = ParticleSetupCommandTypeNone;
                    }
                }];
            }
            else
            {
                completion(nil, [NSError errorWithDomain:@"ParticleSetupCommManangerError" code:2002 userInfo:@{NSLocalizedDescriptionKey:@"Cannot process connectAP command data to JSON"}]);
            }
            
        };
        
        [self openConnection];
    }
    
}


-(void)publicKey:(void (^)(id, NSError *))completion
{
    if ([self canSendCommandCallCompletionForError:completion])
    {
        __weak ParticleSetupCommManager *weakSelf = self;
        self.commandCompletionBlock = completion;
        
        self.commandSendBlock = ^{
            
            weakSelf.commandType = ParticleSetupCommandTypePublicKey;
            NSString *commandStr = @"public-key\n0\n\n";
            
            [weakSelf.connection writeString:commandStr completion:^(NSError *error) {
                if ((error) && (completion))
                {
                    completion(nil, error);
                    weakSelf.commandCompletionBlock = nil;

                }
            }];
            
        };
        
        [self openConnection];
        
    }

}

-(void)dealloc
{
//    NSLog(@"ParticleSetupCommManager %@ dealloced!",self);
    
    self.commandSendBlock = nil;
    self.commandCompletionBlock = nil;
    self.connection = nil;
    
}



@end
