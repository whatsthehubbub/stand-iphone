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

@synthesize maxX;
@synthesize maxY;
@synthesize maxZ;

@synthesize startTime;
@synthesize endTime;
@synthesize secondTimer;

@synthesize containerView;
@synthesize subView;

@synthesize startView;

@synthesize standingView;
@synthesize standingTimeLabel;

@synthesize graceView;

@synthesize doneView;
@synthesize doneTimeLabel;
@synthesize doneLabel;

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
    
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"StartView" owner:nil options:nil];
    
    NSLog(@"Array %@", xibArray);
    
    for (id xibObject in xibArray) {
        if ([xibObject isKindOfClass:[UIView class]]) {
            self.subView = xibObject;
            [self.containerView addSubview:self.subView];
        }
    }
    

//    self.messageLabel.text = @"Start standing!\nPress and hold the button; no walking, no moving.";
    
    self.startedStanding = NO;
    self.gracePeriod = NO;
    self.stoppedStanding = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startStanding {
    if (nil == motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    
    self.stoppedStanding = NO;
    self.startTime = [[NSDate alloc] init];
    self.startedStanding = YES;
    
    [self showStandingView];
    
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
            
//            self.messageLabel.text = [NSString stringWithFormat:@"Current: %f,%f,%f\nMax: %f,%f,%f", userAcceleration.x, userAcceleration.y, userAcceleration.z, maxX, maxY, maxZ];
            
            if (maxX > 0.1 && maxY > 0.1 && maxZ > 0.1) {
                // Done standing, you did a step
                
                [self stopStanding];
            } else {
                maxX -= 0.01;
                maxY -= 0.01;
                maxZ -= 0.01;
            }
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"started touching the screen");
    
    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.touchView];
    
    // TODO these checks don't work anymore?
    if (YES || touch.view == self.touchView) {
        if (!self.startedStanding) {
            [self startStanding];
        } else if (self.gracePeriod) {
            self.gracePeriod = NO;
        }
        
        [self showStandingView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Keep touching the screen");
    
    if (self.startedStanding) {
        self.gracePeriod = YES;
        self.graceStarted = [[NSDate alloc] init];
        
        [self showGraceView];
    }
}

- (void)incrementTime {
    if (!self.gracePeriod && !self.stoppedStanding) {
        self.endTime = [[NSDate alloc] init];
        
        NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
        
        NSString *timeText = [NSString stringWithFormat:@"00:%d", (int)interval];
        self.standingTimeLabel.text = timeText;
        self.doneTimeLabel.text = timeText;
        
        NSLog(@"Time increment normal");
    } else if (self.gracePeriod) {
        
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval interval = [now timeIntervalSinceDate:self.graceStarted];
        
//        self.timeLabel.text = [NSString stringWithFormat:@"in second %d of grace", (int)interval];
        
        NSLog(@"Time increment grace %d", (int)interval);
        
        if (interval > 5) {
            [self stopStanding];
        }
    }
}

- (void)stopStanding {
    self.stoppedStanding = YES;
    
    [self showDoneView];

    
    [self.motionManager stopDeviceMotionUpdates];
    [self.secondTimer invalidate];
    
    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
//    self.timeLabel.text = [NSString stringWithFormat:@"Done standing! Time: %d seconds", (int)interval];
}

- (void)showStartView {
    
}

- (void)showStandingView {
    [self.subView removeFromSuperview];
    
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"StandingView" owner:nil options:nil];
    
    for (id xibObject in xibArray) {
        if ([xibObject isKindOfClass:[UIView class]]) {
            self.subView = xibObject;
            [self.containerView addSubview:self.subView];
        }
    }
}

- (void)showGraceView {
    [self.subView removeFromSuperview];
    
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"GraceView" owner:nil options:nil];
    
    for (id xibObject in xibArray) {
        if ([xibObject isKindOfClass:[UIView class]]) {
            self.subView = xibObject;
            [self.containerView addSubview:self.subView];
        }
    }
}

- (void)showDoneView {
    [self.subView removeFromSuperview];
    
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"DoneView" owner:nil options:nil];
    
    for (id xibObject in xibArray) {
        if ([xibObject isKindOfClass:[UIView class]]) {
            self.subView = xibObject;
            [self.containerView addSubview:self.subView];
        }
    }
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
