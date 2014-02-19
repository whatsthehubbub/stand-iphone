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

@synthesize standingHours;
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
    
    self.standingView = [self loadSubViewFromNib:@"StandingView"];
    self.standingHours = (UILabel *)[self.standingView viewWithTag:14];
    self.standingMinutes = (UILabel *)[self.standingView viewWithTag:12];
    self.standingSeconds = (UILabel *)[self.standingView viewWithTag:13];
    
    self.graceView = [self loadSubViewFromNib:@"GraceView"];
    self.graceButton = (UIImageView *)[self.graceView viewWithTag:11];
    
    self.doneView = [self loadSubViewFromNib:@"DoneView"];
    self.doneMinutes = (UILabel *)[self.doneView viewWithTag:12];
    self.doneSeconds = (UILabel *)[self.doneView viewWithTag:13];
    self.shareButton = (UIButton *)[self.doneView viewWithTag:14];
    [self.shareButton addTarget:self action:@selector(shareResult) forControlEvents:UIControlEventTouchUpInside];
    self.againButton = (UIButton *)[self.doneView viewWithTag:15];
    [self.againButton addTarget:self action:@selector(prepareStanding) forControlEvents:UIControlEventTouchUpInside];

    [self prepareStanding];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareStanding {
    [self setTimeOnViews:0];
    
    self.startedStanding = NO;
    self.gracePeriod = NO;
    self.stoppedStanding = NO;
    
    self.maxX = 0.0;
    self.maxY = 0.0;
    self.maxZ = 0.0;
    
    [self showStartView];
}

- (void)startStanding {
    
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
        
        NSURL *url = [NSURL URLWithString:@"http://standforsomething.herokuapp.com/catch"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
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
    if (!self.stoppedStanding && (touch.view == self.startButton || touch.view == self.graceButton)) {
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
    
    if (self.startedStanding && !self.stoppedStanding) {
        self.gracePeriod = YES;
        self.graceStarted = [[NSDate alloc] init];
        
        [self showGraceView];
    }
}

- (void)incrementTime {
    if (!self.gracePeriod && !self.stoppedStanding) {
        self.endTime = [[NSDate alloc] init];
        
        NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
        
        // Update duration in our shared object
        standManager.duration = (int)interval;
        
        [self setTimeOnViews:interval];

        
        if ((int)interval % 20/*240*/ == 0) {
            // Send a keep alive to the server every four minutes with data about the time
            NSLog(@"Sending keep alive");
            
            NSDictionary *parameters = @{@"secret": standManager.secret, @"sessionid": [NSNumber numberWithInt:standManager.sessionid]};
            
            NSURL *url = [NSURL URLWithString:@"http://standforsomething.herokuapp.com/live"];
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
    } else if (self.gracePeriod) {
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval interval = [now timeIntervalSinceDate:self.graceStarted];
        
        NSLog(@"Time increment grace %d", (int)interval);
        
        if (interval > 5) {
            [self stopStanding];
        }
    }
}

- (void)setTimeOnViews:(NSTimeInterval)interval {
    interval = (int)interval + 3600;
    
    int hours = (int)interval / (60 * 60);
    int minutes = ((int)interval - (hours * 60 * 60)) / 60;
    int seconds = (int)interval - (hours * 60 * 60) - (minutes * 60);
    
    self.standingHours.text = [NSString stringWithFormat:@"%02d", hours];
    self.standingMinutes.text = [NSString stringWithFormat:@"%02d", minutes];
    self.standingSeconds.text = [NSString stringWithFormat:@"%02d", seconds];
    
    self.doneMinutes.text = [NSString stringWithFormat:@"%02d", ((int)interval)/60];
    self.doneSeconds.text = [NSString stringWithFormat:@"%02d", ((int)interval) % 60];
}

- (void)stopStanding {
    // Stop standing does not make sense if we don't get a response from the server
    // TODO how does it behave then? or when somebody deos not have internet?
    
    self.stoppedStanding = YES;
    
    [self showDoneView];
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Starting second block");
        
        NSDictionary *parameters = @{@"secret": standManager.secret, @"sessionid": [NSNumber numberWithInt:standManager.sessionid], @"duration": [NSNumber numberWithInt:standManager.duration]};
        
        NSURL *url = [NSURL URLWithString:@"http://standforsomething.herokuapp.com/done"];
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
