//
//  StandManager.m
//  Stand for Something
//
//  Created by Alper Cugun on 11/2/14.
//  Copyright (c) 2014 Hubbub. All rights reserved.
//

#import "StandManager.h"

@implementation StandManager

@synthesize coordinate;
@synthesize duration;

@synthesize sessionid;
@synthesize secret;

@synthesize message;

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
        secret = nil;
        message = @"something";
    }
    
//    // Test seconds
//    NSLog(@"Trying out duration of %d and get: %@", 0, [self getDurationString:0]);
//    NSLog(@"Trying out duration of %d and get: %@", 1, [self getDurationString:1]);
//    NSLog(@"Trying out duration of %d and get: %@", 2, [self getDurationString:2]);
//    
//    // Test minutes
//    NSLog(@"Trying out duration of %d and get: %@", 59, [self getDurationString:59]);
//    NSLog(@"Trying out duration of %d and get: %@", 60, [self getDurationString:60]);
//    NSLog(@"Trying out duration of %d and get: %@", 61, [self getDurationString:61]);
//    NSLog(@"Trying out duration of %d and get: %@", 62, [self getDurationString:62]);
//    NSLog(@"Trying out duration of %d and get: %@", 122, [self getDurationString:122]);
//    
//    // Test hours
//    NSLog(@"Trying out duration of %d and get: %@", 3599, [self getDurationString:3599]);
//    NSLog(@"Trying out duration of %d and get: %@", 3600, [self getDurationString:3600]);
//    NSLog(@"Trying out duration of %d and get: %@", 3601, [self getDurationString:3601]);
//    NSLog(@"Trying out duration of %d and get: %@", 3602, [self getDurationString:3602]);
//    NSLog(@"Trying out duration of %d and get: %@", 3700, [self getDurationString:3700]);
//    NSLog(@"Trying out duration of %d and get: %@", 6000, [self getDurationString:6000]);
//    NSLog(@"Trying out duration of %d and get: %@", 7999, [self getDurationString:7999]);
//    
//    // Test days
//    NSLog(@"Trying out duration of %d and get: %@", 86399, [self getDurationString:86399]);
//    NSLog(@"Trying out duration of %d and get: %@", 86400, [self getDurationString:86400]);
//    NSLog(@"Trying out duration of %d and get: %@", 86401, [self getDurationString:86401]);
//    NSLog(@"Trying out duration of %d and get: %@", 86402, [self getDurationString:86402]);
//    NSLog(@"Trying out duration of %d and get: %@", 87000, [self getDurationString:87000]);
//    NSLog(@"Trying out duration of %d and get: %@", 90000, [self getDurationString:90000]);
//    NSLog(@"Trying out duration of %d and get: %@", 100000, [self getDurationString:100000]);
    
    
    return self;
}

- (NSString *)getDurationString {
    return [self getDurationStringWithOrWithoutBreaks:NO];
}

- (NSString *)getDurationStringWithBreaks {
    return [self getDurationStringWithOrWithoutBreaks:YES];
}

- (NSString *)getDurationStringWithOrWithoutBreaks:(BOOL)breaks {
    // Convert duration is seconds to a proper string of two parts resolution
    
    // In some cases we want a space after "and" in other cases we want a linebreak
    NSString *breakString = breaks ? @"\n" : @" ";
    
    NSMutableString *returnString;
    
    if (duration >= 24*60*60) {
        // 1 day or more
        int days = duration / (24 * 60 * 60);
        int hours = (duration - (days * 24 * 60 * 60)) / (60*60);
        int minutes = (duration - (days * 24 * 60 * 60) - (hours * 60 * 60)) / 60;
        int seconds = duration - (days * 24 * 60 * 60) - (hours * 60 * 60) - (minutes * 60);

        returnString = [NSMutableString stringWithFormat:@"%d %@", days, (days == 1 ? @"day": @"days")];
        
        if (hours > 0) {
            [returnString appendString:[NSString stringWithFormat:@" and%@%d %@", breakString, hours, (hours == 1 ? @"hour" : @"hours")]];
        } else if (minutes > 0) {
            [returnString appendString:[NSString stringWithFormat:@" and%@%d %@", breakString, minutes, (minutes == 1 ? @"minute" : @"minutes")]];
        } else if (seconds > 0) {
            [returnString appendString:[NSString stringWithFormat:@" and%@%d %@", breakString, seconds, (seconds == 1 ? @"second" : @"seconds")]];
        }
    } else if (duration >= 60*60) {
        // 1 hour or more
        int hours = duration / (60*60);
        int minutes = (duration - (hours * 60 * 60)) / 60;
        int seconds = duration - (hours * 60 * 60) - (minutes * 60);
        
        returnString = [NSMutableString stringWithFormat:@"%d %@", hours, (hours == 1 ? @"hour": @"hours")];
        
        if (minutes > 0) {
            [returnString appendString:[NSString stringWithFormat:@" and%@%d %@", breakString, minutes, (minutes == 1 ? @"minute" : @"minutes")]];
        } else {
            // Minutes is zero
            if (seconds > 0) {
                // There are seconds
                [returnString appendString:[NSString stringWithFormat:@" and%@%d %@", breakString, seconds, (seconds == 1 ? @"second" : @"seconds")]];
            }
        }
        
    } else if (duration >= 60) {
        // 1 minute or more
        int minutes = duration / 60;
        int seconds = duration - (minutes * 60);
        
        returnString = [NSMutableString stringWithFormat:@"%d %@", minutes, (minutes == 1 ? @"minute": @"minutes")];
        
        if (seconds > 0) {
            [returnString appendString:[NSString stringWithFormat:@" and%@%d %@", breakString, seconds, (seconds == 1 ? @"second" : @"seconds")]];
        }
    } else {
        // Seconds
        if (duration == 1) {
            returnString = [NSMutableString stringWithString:@"1 second"];
        } else {
            returnString = [NSMutableString stringWithFormat:@"%d seconds", duration];
        }
    }
    
    return (NSString *)returnString;
}

#pragma mark UIActivityItemSource methods

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        NSString *twitterText = [NSString stringWithFormat:@"I stood %@ for %@ with @getstanding", [self getDurationString], self.message];
        
        return twitterText;
    } else {
        NSString *text = [NSString stringWithFormat:@"I stood %@ for %@ with the Standing app.", [self getDurationString], self.message];
        
        return text;
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return [NSString stringWithFormat:@"I stood for %@", self.message];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

@end
