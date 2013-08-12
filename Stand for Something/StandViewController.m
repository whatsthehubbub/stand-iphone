//
//  StandViewController.m
//  Stand for Something
//
//  Created by Alper Cugun on 12/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import "StandViewController.h"

@interface StandViewController ()

@end

@implementation StandViewController

@synthesize motionManager;

@synthesize motionLabel;

@synthesize maxX;
@synthesize maxY;
@synthesize maxZ;

@synthesize startTime;
@synthesize endTime;
@synthesize secondTimer;

@synthesize timeLabel;

@synthesize touchView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startStanding {
    NSLog(@"Start standing");
    
    if (nil == motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    
    self.startTime = [[NSDate alloc] init];
    
//    self.secondTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(incrementTime) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:self.secondTimer forMode:NSRunLoopCommonModes];
//    [[NSRunLoop mainRunLoop] addTimer:self.secondTimer forMode:UITrackingRunLoopMode];
    
    self.secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTime) userInfo:nil repeats:YES];
    
    motionManager.deviceMotionUpdateInterval = 1/15.0;
    
    if (motionManager.deviceMotionAvailable) {
        //        NSLog(@"Device motion available");
        
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            
            CMAcceleration userAcceleration = motion.userAcceleration;
            
            maxX = MAX(ABS(maxX), ABS(userAcceleration.x));
            maxY = MAX(ABS(maxY), ABS(userAcceleration.y));
            maxZ = MAX(ABS(maxZ), ABS(userAcceleration.z));
            
            self.motionLabel.text = [NSString stringWithFormat:@"Current: %f,%f,%f\nMax: %f,%f,%f", userAcceleration.x, userAcceleration.y, userAcceleration.z, maxX, maxY, maxZ];
            
            if (maxX > 0.1 && maxY > 0.1 && maxZ > 0.1) {
                // Done standing, you did a step
                
                [self stopStanding];
            } else {
                maxX -= 0.01;
                maxY -= 0.01;
                maxZ -= 0.01;
            }
            
            //            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motionManager waitUntilDone:YES];
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"started touching the screen");
    
    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.touchView];
    
    if (touch.view == self.touchView) {
        NSLog(@"Started touching the screen in the correct view");
        
        [self startStanding];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Keep touching the screen");
    
    self.timeLabel.text = @"Keep touching the screen to go on.";
}

- (void)incrementTime {
    NSLog(@"in time increment");
    self.endTime = [[NSDate alloc] init];
    
    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%d seconds", (int)interval];
}

- (void)stopStanding {
    self.stoppedStanding = YES;
    
    [self.motionManager stopDeviceMotionUpdates];
    [self.secondTimer invalidate];
    
    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
    self.timeLabel.text = [NSString stringWithFormat:@"Done standing! Time: %d seconds", (int)interval];
}

- (void)startGrace {
    self.gracePeriod = YES;
}

- (void)endGrace {
    self.gracePeriod = NO;
}

@end
