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

@synthesize locationManager;
@synthesize currentLocation;

@synthesize standManager;

@synthesize urlSession;
@synthesize requestOperation;

@synthesize motionManager;

@synthesize smoothX;
@synthesize smoothY;
@synthesize smoothZ;

@synthesize standingState;
@synthesize graceStarted;

@synthesize startTime;
@synthesize endTime;
@synthesize secondTimer;

@synthesize containerView;
@synthesize startView;
@synthesize standingView;
@synthesize graceView;
@synthesize doneView;

@synthesize startButton;
@synthesize aboutButton;

@synthesize standingHours;
@synthesize standingMinutes;
@synthesize standingSeconds;

@synthesize graceButton;

@synthesize doneText;

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
    
    self.standManager = [StandManager sharedManager];
    
    // Setup the location stuff
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 200;
    
    [self.locationManager startUpdatingLocation];
    
    
    // Dump container view size
    NSLog(@"Container view size %f x %f", self.containerView.frame.size.width, self.containerView.frame.size.height);
    
    NSLog(@"Container view origin %f x %f", self.containerView.frame.origin.x, self.containerView.frame.origin.y);
    
    // Load all the subviews
    self.startView = [self loadSubViewFromNib:@"StartView"];
    self.startButton = (UIImageView *)[self.startView viewWithTag:11];
    self.aboutButton = (UIButton *)[self.startView viewWithTag:12];
    [self.aboutButton addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];
    
    self.standingView = [self loadSubViewFromNib:@"StandingView"];
    self.standingHours = (UILabel *)[self.standingView viewWithTag:14];
    self.standingMinutes = (UILabel *)[self.standingView viewWithTag:12];
    self.standingSeconds = (UILabel *)[self.standingView viewWithTag:13];
    
    // Set custom fonts on text
    CGFloat timeSize = self.standingHours.font.pointSize;
    self.standingHours.font = [UIFont fontWithName:@"CourierPrime-Bold" size:timeSize];
    self.standingMinutes.font = [UIFont fontWithName:@"CourierPrime-Bold" size:timeSize];
    self.standingSeconds.font = [UIFont fontWithName:@"CourierPrime-Bold" size:timeSize];
    
    self.graceView = [self loadSubViewFromNib:@"GraceView"];
    self.graceButton = (UIImageView *)[self.graceView viewWithTag:11];
    
    self.doneView = [self loadSubViewFromNib:@"DoneView"];
    self.doneText = (UILabel *)[self.doneView viewWithTag:12];
    self.shareButton = (UIButton *)[self.doneView viewWithTag:14];
    [self.shareButton addTarget:self action:@selector(shareResult) forControlEvents:UIControlEventTouchUpInside];
    self.againButton = (UIButton *)[self.doneView viewWithTag:15];
    [self.againButton addTarget:self action:@selector(enterStandingBeforeState) forControlEvents:UIControlEventTouchUpInside];

    [self enterStandingBeforeState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enterStandingBeforeState {
    [self setTimeOnViews:0];
    
    self.standingState = StandingBefore;
    
    self.smoothX = 0.0;
    self.smoothY = 0.0;
    self.smoothZ = 0.0;
    
    [self showStartView];
}

- (void)enterStandingDuringState {
    self.standingState = StandingDuring;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Get location from StandManager
    NSLog(@"Got location back from store %f", standManager.coordinate.latitude);
    
    // Post it to our webservice
    NSDictionary *parameters = @{@"lat": [[NSNumber numberWithDouble:standManager.coordinate.latitude] stringValue], @"lon": [[NSNumber numberWithDouble:standManager.coordinate.longitude] stringValue], @"vendorid": [[[UIDevice currentDevice] identifierForVendor] UUIDString]};
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:delegateQueue];
    
    self.requestOperation = [NSBlockOperation blockOperationWithBlock:^{}];
    
    // Going to touch this reference on self inside the block so need a weak reference
    __weak NSBlockOperation *weakBlockOp = self.requestOperation;
    
    NSOperation *firstOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Start first block");
        
        NSURL *url = [NSURL URLWithString:@"http://www.getstanding.com/catch"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSLog(@"Sending data to server %@", [parameters urlEncodedString]);
        
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[parameters urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionDataTask *postDataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            // We absolutely need the stuff from this completion handler to work with later which is why
            // we add it to a NSBlockoperation we defined earlier so we can depend on it
            [weakBlockOp addExecutionBlock:^{
                NSError *jsonError = nil;
                NSDictionary *json = nil;
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                NSLog(@"Got data %@", json);
                
                standManager.secret = [json objectForKey:@"secret"];
                standManager.sessionid = [[json objectForKey:@"sessionid"] intValue];
                
                // Reset these to reasonable defaults
                standManager.duration = 0;
                standManager.message = @"something";
                
                NSLog(@"Finishing first request");
            }];
            
            [self.urlSession.delegateQueue addOperation:self.requestOperation];
        }];
        
        [postDataTask resume];
        
        NSLog(@"Finish first block");
    }];
    
    [self.urlSession.delegateQueue addOperation:firstOperation];
    
    
    if (nil == motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    
    self.startTime = [[NSDate alloc] init];
    
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
            
            double RC = 0.4;
            double alpha = 1/15.0 / (RC + 1/15.0);
            
            smoothX = (alpha * ABS(userAcceleration.x)) + (1.0 - alpha) * smoothX;
            smoothY = (alpha * ABS(userAcceleration.y)) + (1.0 - alpha) * smoothY;
            smoothZ = (alpha * ABS(userAcceleration.z)) + (1.0 - alpha) * smoothZ;

//            NSLog(@"Smooth motion: %.2f, %.2f, %.2f", smoothX, smoothY, smoothZ);
            
            double smoothSum = smoothX + smoothY + smoothZ;
            
            if (smoothSum > 0.2) {
                // Done standing, you did a step
                
                [self enterStandingDoneState];
            } else if (self.standingState == StandingDuring && smoothSum > 0.1) {
                // Show the grace view for too much movement
                
                NSLog(@"Quit moving so much");
                
                if (self.standingState == StandingDuring) {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    
                    self.graceStarted = [[NSDate alloc] init];
                    self.standingState = StandingGraceMovement;
                    
                    [self showGraceView];
                }
            } else if (self.standingState == StandingGraceMovement && smoothSum <= 0.1) {
                // Stop showing the grace view because movement is within parameters again
                
                // But wait for at least one second
                NSDate *now = [[NSDate alloc] init];
                NSTimeInterval graceInterval = [now timeIntervalSinceDate:self.graceStarted];
                
                if ((int) graceInterval > 1.0) {
                    self.standingState = StandingDuring;
                    [self showStandingView];
                }
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
        if (self.standingState==StandingBefore) {
            [self enterStandingDuringState];
        } else if (self.standingState == StandingGraceTouch) {
            self.standingState = StandingDuring;
            [self showStandingView];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches ended");
    
    if (self.standingState == StandingDuring || self.standingState == StandingGraceMovement) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        self.standingState = StandingGraceTouch;
        self.graceStarted = [[NSDate alloc] init];
        [self showGraceView];
    }
}

- (void)incrementTime {
    self.endTime = [[NSDate alloc] init];
    
    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
    
    // Update duration in our shared object
    standManager.duration = (int)interval;
    
    [self setTimeOnViews:interval];
    
    if (self.standingState == StandingDuring) {
        if ((int)interval % 60 /*240*/ == 0) {
            // Send a keep alive to the server every minute with data about the time
            NSLog(@"Sending keep alive");
            
            NSDictionary *parameters = @{@"secret": standManager.secret, @"sessionid": [NSNumber numberWithInt:standManager.sessionid]};
            
            NSURL *url = [NSURL URLWithString:@"http://www.getstanding.com/live"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[[parameters urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSURLSessionDataTask *postDataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                NSError *jsonError = nil;
                NSDictionary *json = nil;
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                NSLog(@"Got data %@", json);
            }];
            
            [postDataTask resume];
        }
        
        NSLog(@"Time increment normal");
    } else if (self.standingState == StandingGraceTouch) {
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval graceInterval = [now timeIntervalSinceDate:self.graceStarted];
        
        NSLog(@"Time increment grace %d", (int)graceInterval);
        
        if (graceInterval > 0) {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        
        if (graceInterval > 5) {
            [self enterStandingDoneState];
        }
    }
}

- (void)setTimeOnViews:(NSTimeInterval)interval {
    int hours = (int)interval / (60 * 60);
    int minutes = ((int)interval - (hours * 60 * 60)) / 60;
    int seconds = (int)interval - (hours * 60 * 60) - (minutes * 60);
    
    self.standingHours.text = [NSString stringWithFormat:@"%02d", hours];
    self.standingMinutes.text = [NSString stringWithFormat:@"%02d", minutes];
    self.standingSeconds.text = [NSString stringWithFormat:@"%02d", seconds];
    
    self.doneText.text = [NSString stringWithFormat:@"Done.\nYou stood %@.", [standManager getDurationString]];
}

- (void)enterStandingDoneState {
    self.standingState = StandingDone;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self showDoneView];
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Starting second block");
        
        NSDictionary *parameters = @{@"secret": standManager.secret, @"sessionid": [NSNumber numberWithInt:standManager.sessionid], @"duration": [NSNumber numberWithInt:standManager.duration]};
        
        NSURL *url = [NSURL URLWithString:@"http://www.getstanding.com/done"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[parameters urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionDataTask *postDataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSError *jsonError = nil;
            NSDictionary *json = nil;
            json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            NSLog(@"Got data %@", json);
        }];
        
        [postDataTask resume];
    }];
    
    
    // This is where we depend on the content of the completion handler for this block, otherwise it can't find sessionids and crashes
    [operation addDependency:self.requestOperation];
    [self.urlSession.delegateQueue addOperation:operation];
    
    [self.motionManager stopDeviceMotionUpdates];
    [self.secondTimer invalidate];
    
//    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
//    self.timeLabel.text = [NSString stringWithFormat:@"Done standing! Time: %d seconds", (int)interval];
}

- (void)shareResult {
    [self performSegueWithIdentifier:@"ShareModal" sender:self];
}

- (void)showAbout {
    [self performSegueWithIdentifier:@"ShowAbout" sender:self];
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    
    NSLog(@"Get location %f x %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    // Store the current location in our model
    standManager.coordinate = self.currentLocation.coordinate;
}

@end
