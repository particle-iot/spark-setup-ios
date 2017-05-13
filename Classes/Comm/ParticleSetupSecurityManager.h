//
//  ParticleSetupSecurity.h
//  teacup-ios-app
//
//  Created by Ido Kleinman on 1/8/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParticleSetupSecurityManager : NSObject

+(SecKeyRef)getPublicKey;
+(BOOL)setPublicKey:(NSData *)rawASN1FormattedKey;
+(NSData *)encryptWithPublicKey:(SecKeyRef)pubKey plainText:(NSData *)plainText;
+(NSData *)decodeDataFromHexString:(NSString *)hexEncodedString;
+(NSString *)encodeDataToHexString:(NSData *)buffer;

@end
