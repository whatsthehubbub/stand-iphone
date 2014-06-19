//
//  StandManager.h
//  Stand for Something
//
//  Created by Alper Cugun on 11/2/14.
//  Copyright (c) 2014 Hubbub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface StandManager : NSObject

@property (readwrite) CLLocationCoordinate2D coordinate;
@property (readwrite) int duration;

@property (readwrite) int sessionid;
@property (strong) NSString *secret;

@property (strong) NSString *message;

+(id)sharedManager;

- (NSString *)getDurationString;
- (NSString *)getDurationStringWithBreaks;
- (NSString *)getDurationStringWithOrWithoutBreaks:(BOOL)breaks;

@end
