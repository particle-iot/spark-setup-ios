//
//  ParticleEvent.h
//  Pods
//
//  Created by Ido on 7/14/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ParticleEvent;

typedef void (^ParticleEventHandler)(ParticleEvent * _Nullable event, NSError * _Nullable error);

@interface ParticleEvent : NSObject

@property (nonatomic, strong) NSString *deviceID;   // Event published by this device ID
@property (nonatomic, nullable, strong) NSString *data;  // Event payload in string format
@property (nonatomic, strong) NSString *event;      // Event name
@property (nonatomic, strong) NSDate *time;         // Event "published at" time/date UTC
@property (nonatomic) NSInteger ttl;                // Event time to live (currently unused)

/**
 *  Particle event handler class initializer which receives a dictionary argument
 *
 *  @param eventDict NSDictionary argument which contains the event payload keys: event (name), data (payload), ttl (time to live), published_at (date/time published), coreid (publishiing device ID).
 */
-(instancetype)initWithEventDict:(NSDictionary *)eventDict;

@end

NS_ASSUME_NONNULL_END
