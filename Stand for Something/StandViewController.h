//
//  StandViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 12/8/13.
//  Copyright (c) 2014 Hubbub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Social/Social.h>

#import "StandManager.h"
#import "NSDictionary+URLEncoding.h"

@interface StandViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate>

@property (assign) BOOL showIntro;

@property (strong) CLLocationManager *locationManager;
// TODO remove currentLocation?
@property (strong) CLLocation *currentLocation;

@property (strong) StandManager *standManager;

@property (strong) NSURLSession *urlSession;
@property (strong) NSBlockOperation *requestOperation;

@property (strong) CMMotionManager *motionManager;

@property (assign) double smoothX;
@property (assign) double smoothY;
@property (assign) double smoothZ;

typedef NS_ENUM(NSInteger, StandingState) {
    StandingBefore,
    StandingDuring,
    StandingGraceMovement,
    StandingGraceTouch,
    StandingDone,
    TypingText
};

// Object where we store all touches on the correct view over their lifetime
@property (strong) NSMutableSet *currentTouches;

@property (assign) StandingState standingState;

@property (strong) NSDate *startTime;
@property (strong) NSDate *endTime;
@property (strong) NSTimer *secondTimer;
// Seconds the app has been in grace and which are deducted from the time actually standing
@property (assign) double pauseSeconds;

@property (strong) NSTimer *graceTimer;
@property (strong) NSDate *graceStart;

@property (strong) IBOutlet UIView *containerView;
@property (strong) UIView *startView;
@property (strong) UIView *standingView;
@property (strong) UIView *graceView;
@property (strong) UIView *doneView;

// Start view controls
@property (strong) IBOutlet UIImageView *startButton;
@property (strong) IBOutlet UIButton *aboutButton;
@property (strong) IBOutlet UITextField *textField;

// Standing view controls
@property (strong) IBOutlet UILabel *standingHours;
@property (strong) IBOutlet UILabel *standingMinutes;
@property (strong) IBOutlet UILabel *standingSeconds;

// Grace view controls
@property (strong) IBOutlet UIImageView *graceButton;

// Done view controls
@property (strong) IBOutlet UILabel *doneText;
@property (strong) IBOutlet UIButton *tweetButton;
@property (strong) IBOutlet UIButton *webButton;
@property (strong) IBOutlet UIButton *againButton;

- (void)startStanding;

@end
