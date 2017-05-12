//
//  ParticleSetupConnection.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/20/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ParticleSetupConnection;

typedef NS_ENUM(NSInteger, ParticleSetupConnectionState) {
    ParticleSetupConnectionStateOpened,
//    ParticleSetupConnectionStateSentCommand,
//    ParticleSetupConnectionStateReceivedResponse,
    ParticleSetupConnectionStateClosed,
    ParticleSetupConnectionOpenTimeout,
    ParticleSetupConnectionStateError,
    ParticleSetupConnectionStateUnknown
};


@protocol ParticleSetupConnectionDelegate <NSObject>

@required
-(void)ParticleSetupConnection:(ParticleSetupConnection *)connection didReceiveData:(NSString *)data;

@optional
-(void)ParticleSetupConnection:(ParticleSetupConnection *)connection didUpdateState:(ParticleSetupConnectionState)state error:(NSError *)error;

@end

@interface ParticleSetupConnection : NSObject
-(instancetype)initWithIPAddress:(NSString *)IPAddr port:(int)port NS_DESIGNATED_INITIALIZER;
-(id)init __attribute__((unavailable("Must use -initWithIPAddress:port:")));
-(void)close;

@property (nonatomic, strong) id<ParticleSetupConnectionDelegate>delegate;
@property (nonatomic, readonly) ParticleSetupConnectionState state;

-(void)writeString:(NSString *)string completion:(void(^)(NSError *error))completion;

@end
