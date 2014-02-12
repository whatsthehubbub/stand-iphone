//
//  StandViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 12/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>

#import "StandManager.h"
#import "AFNetworking.h"

@interface StandViewController : UIViewController <CLLocationManagerDelegate>

@property (strong) CLLocationManager *locationManager;
// TODO remove currentLocation?
@property (strong) CLLocation *currentLocation;

@property (strong) StandManager *standManager;


@property (strong) CMMotionManager *motionManager;

@property (assign) double maxX;
@property (assign) double maxY;
@property (assign) double maxZ;

@property (assign) BOOL startedStanding;
@property (assign) BOOL gracePeriod;
@property (strong) NSDate *graceStarted;
@property (assign) BOOL stoppedStanding;

@property (strong) NSDate *startTime;
@property (strong) NSDate *endTime;
@property (strong) NSTimer *secondTimer;

@property (strong) IBOutlet UIView *containerView;
@property (strong) UIView *startView;
@property (strong) UIView *standingView;
@property (strong) UIView *graceView;
@property (strong) UIView *doneView;

@property (strong) IBOutlet UIImageView *startButton;

@property (strong) IBOutlet UILabel *standingMinutes;
@property (strong) IBOutlet UILabel *standingSeconds;

@property (strong) IBOutlet UIImageView *graceButton;

@property (strong) IBOutlet UILabel *doneMinutes;
@property (strong) IBOutlet UILabel *doneSeconds;
@property (strong) IBOutlet UIButton *tweetButton;

- (void)startStanding;

@end
