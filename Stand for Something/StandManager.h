//
//  StandManager.h
//  Stand for Something
//
//  Created by Alper Cugun on 11/2/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface StandManager : NSObject

@property (readwrite) CLLocationCoordinate2D location;

+(id)sharedManager;

@end
