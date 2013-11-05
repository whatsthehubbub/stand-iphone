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
@synthesize startView;
@synthesize standingView;
@synthesize graceView;
@synthesize doneView;

@synthesize startButton;

@synthesize standingMinutes;
@synthesize standingSeconds;

@synthesize graceButton;

@synthesize doneMinutes;
@synthesize doneSeconds;

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
    
    // Dump container view size
    NSLog(@"Container view size %f x %f", self.containerView.frame.size.width, self.containerView.frame.size.height);
    
    NSLog(@"Container view origin %f x %f", self.containerView.frame.origin.x, self.containerView.frame.origin.y);
    
    // Load all the subviews
    self.startView = [self loadSubViewFromNib:@"StartView"];
    
    NSLog(@"Start view size %f x %f", self.startView.frame.size.width, self.startView.frame.size.height);
    
    NSLog(@"Start view origin %f x %f", self.startView.frame.origin.x, self.startView.frame.origin.y);
    
    self.startButton = (UIImageView *)[self.startView viewWithTag:11];
    
    self.standingView = [self loadSubViewFromNib:@"StandingView"];
    
    self.standingMinutes = (UILabel *)[self.standingView viewWithTag:12];
    self.standingSeconds = (UILabel *)[self.standingView viewWithTag:13];
    
    self.graceView = [self loadSubViewFromNib:@"GraceView"];
    
    self.graceButton = (UIImageView *)[self.graceView viewWithTag:11];
    
    self.doneView = [self loadSubViewFromNib:@"DoneView"];
    
    self.doneMinutes = (UILabel *)[self.doneView viewWithTag:12];
    self.doneSeconds = (UILabel *)[self.doneView viewWithTag:13];
    
    self.startView.hidden = NO;
    

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
//    NSLog(@"started touching the screen");
    
    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.startView];
    
//    NSLog(@"Touch location is %f x %f", location.x, location.y);
    
//    for (UITouch *touchIt in touches) {
//        NSLog(@"Touch registered on %@", touch.view);
//    }
    
//    NSLog(@"Touch View %@", touch.view);
//    NSLog(@"Touch view class %@", [touch.view class]);
//    NSLog(@"Start button %@", self.startButton);
    
//    UIView *descendant = [touch.view hitTest:location withEvent:event];
//    
//    NSLog(@"Hit test %@", descendant);
    
    // TODO these checks don't work anymore. fix them.
    if (touch.view == self.startButton || touch.view == self.graceButton) {
        if (!self.startedStanding) {
            [self startStanding];
        } else if (self.gracePeriod) {
            self.gracePeriod = NO;
        }
        
        [self showStandingView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches ended");
    
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
//        self.standingTimeLabel.text = timeText;
//        self.doneTimeLabel.text = timeText;
        
        self.standingMinutes.text = [NSString stringWithFormat:@"%02d", ((int)interval)/60];
        self.standingSeconds.text = [NSString stringWithFormat:@"%02d", ((int)interval) % 60];
        
        self.doneMinutes.text = [NSString stringWithFormat:@"%02d", ((int)interval)/60];
        self.doneSeconds.text = [NSString stringWithFormat:@"%02d", ((int)interval) % 60];
        
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
    self.startView.hidden = NO;
    self.standingView.hidden = YES;
    self.graceView.hidden = YES;
    self.doneView.hidden = YES;
}

- (void)showStandingView {
    self.startView.hidden = YES;
    self.standingView.hidden = NO;
    self.graceView.hidden = YES;
    self.doneView.hidden = YES;
}

- (void)showGraceView {
    self.startView.hidden = YES;
    self.standingView.hidden = YES;
    self.graceView.hidden = NO;
    self.doneView.hidden = YES;
}

- (void)showDoneView {
    self.startView.hidden = YES;
    self.standingView.hidden = YES;
    self.graceView.hidden = YES;
    self.doneView.hidden = NO;
}

- (UIView *)loadSubViewFromNib:(NSString *)nibName {
    NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    
    UIView *view;
    
    for (id xibObject in xibArray) {
        if ([xibObject isKindOfClass:[UIView class]]) {
            view = xibObject;
            
            view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
            
            [self.containerView addSubview:view];
            view.hidden = YES;
        }
    }
    
    return view;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
