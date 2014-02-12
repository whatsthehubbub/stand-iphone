//
//  StandManager.m
//  Stand for Something
//
//  Created by Alper Cugun on 11/2/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import "StandManager.h"

@implementation StandManager

@synthesize coordinate;
@synthesize duration;

@synthesize sessionid;
@synthesize secret;

+(id)sharedManager {
    static StandManager *sharedStandManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStandManager = [[self alloc] init];
    });
    
    return sharedStandManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

@end
