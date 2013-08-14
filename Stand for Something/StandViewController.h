//
//  StandViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 12/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface StandViewController : UIViewController

@property (strong) CMMotionManager *motionManager;

@property (strong) IBOutlet UILabel *debugLabel;

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

@property (strong) IBOutlet UILabel *timeLabel;

@property (strong) IBOutlet UIImageView *touchView;

- (void)startStanding;

- (IBAction)stopNow:(id)sender;

- (IBAction)close:(id)sender;

@end
