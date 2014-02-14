//
//  StandViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 12/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "StandManager.h"
#import "NSDictionary+URLEncoding.h"

@interface StandViewController : UIViewController <CLLocationManagerDelegate>

@property (strong) CLLocationManager *locationManager;
// TODO remove currentLocation?
@property (strong) CLLocation *currentLocation;

@property (strong) StandManager *standManager;

@property (strong) NSURLSession *urlSession;
@property (strong) NSBlockOperation *requestOperation;

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

// Start view controls
@property (strong) IBOutlet UIImageView *startButton;

// Standing view controls
@property (strong) IBOutlet UILabel *standingMinutes;
@property (strong) IBOutlet UILabel *standingSeconds;

// Grace view controls
@property (strong) IBOutlet UIImageView *graceButton;

// Done view controls
@property (strong) IBOutlet UILabel *doneMinutes;
@property (strong) IBOutlet UILabel *doneSeconds;

@property (strong) IBOutlet UIButton *shareButton;
@property (strong) IBOutlet UIButton *againButton;

- (void)startStanding;

@end
