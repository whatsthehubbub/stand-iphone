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
    [self showStartView];
    
    [self setTimeOnViews:0];
    
    self.startedStanding = NO;
    self.gracePeriod = NO;
    self.stoppedStanding = NO;
}

- (void)startStanding {
    
    // Get location from StandManager
    NSLog(@"Got location back from store %f", standManager.coordinate.latitude);
    // Post it to our webservice
    
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"lat": [[NSNumber numberWithDouble:standManager.coordinate.latitude] stringValue], @"lon": [[NSNumber numberWithDouble:standManager.coordinate.longitude] stringValue], @"vendorid": [[[UIDevice currentDevice] identifierForVendor] UUIDString]};

    [afManager POST:@"http://standforsomething.herokuapp.com/catch" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Server response %@", responseObject);

        
        NSDictionary *json = (NSDictionary *)responseObject;
        
        standManager.secret = [json objectForKey:@"secret"];
        standManager.sessionid = [[json objectForKey:@"sessionid"] intValue];
        
        // Reset these to reasonable defaults
        standManager.duration = 0;
        standManager.sessionid = -1;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST to server failed %@", error);
    }];
    
    
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
        
        standManager.duration = (int)interval;
        
//        NSString *timeText = [NSString stringWithFormat:@"00:%d", (int)interval];
//        self.standingTimeLabel.text = timeText;
//        self.doneTimeLabel.text = timeText;
        
        [self setTimeOnViews:interval];
        
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

- (void)setTimeOnViews:(NSTimeInterval)interval {
    self.standingMinutes.text = [NSString stringWithFormat:@"%02d", ((int)interval)/60];
    self.standingSeconds.text = [NSString stringWithFormat:@"%02d", ((int)interval) % 60];
    
    self.doneMinutes.text = [NSString stringWithFormat:@"%02d", ((int)interval)/60];
    self.doneSeconds.text = [NSString stringWithFormat:@"%02d", ((int)interval) % 60];
}

- (void)stopStanding {
    self.stoppedStanding = YES;
    
    [self showDoneView];
    
    // Update website with the time
    AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"secret": standManager.secret, @"sessionid": [NSNumber numberWithInt:standManager.sessionid], @"duration": [NSNumber numberWithInt:standManager.duration]};
    
    [afManager POST:@"http://standforsomething.herokuapp.com/done" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Server response %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST to server failed %@", error);
    }];

    
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
    
    
//    NSURL *url = [NSURL URLWithString:@"https://api.foursquare.com/v2/venues/search"];
//    NSDictionary *headers = [NSDictionary dictionary];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"E5OLRBH2Z2KW2BHD43V2YTKDTFMUCIPQHBAIULUJDEPEUW05", @"client_id", @"TXJOYFAXMANGKMJKFSERSJDOX0DPZMM5MOUT23K241DCSEJK", @"client_secret", @"20130719", @"v", [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude], @"ll", @"4bf58dd8d48988d164941735,4bf58dd8d48988d163941735", @"categoryId", @"1000", @"radius", nil];
//    
//    FSNConnection *conn = [FSNConnection withUrl:url method:FSNRequestMethodGET headers:headers parameters:parameters parseBlock:^id(FSNConnection *c, NSError **error) {
//        
//        return [c.responseData dictionaryFromJSONWithError:error];
//    } completionBlock:^(FSNConnection *c) {
//        //        NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
//        
//        NSDictionary *result = (NSDictionary *)c.parseResult;
//        self.plazas = [[result objectForKey:@"response"] objectForKey:@"venues"];
//        
//        //        NSLog(@"plazas got %@", self.plazas);
//        
//        
//        [self.tableView reloadData];
//        
//    } progressBlock:^(FSNConnection *c) {
//        //        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
//    }];
//    
//    //    NSLog(@"request %@", conn);
//    
//    [conn start];
}

@end
