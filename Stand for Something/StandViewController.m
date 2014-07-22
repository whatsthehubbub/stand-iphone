//
//  StandViewController.m
//  Stand for Something
//
//  Created by Alper Cugun on 12/8/13.
//  Copyright (c) 2014 Hubbub. All rights reserved.
//

#import "StandViewController.h"

@interface StandViewController ()

@end

@implementation StandViewController

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
    
    self.currentTouches = [[NSMutableSet alloc] init];
    
    // Load all the subviews
    self.startView = [self loadSubViewFromNib:@"StartView"];
    self.startButton = (UIImageView *)[self.startView viewWithTag:11];
    self.startButton.multipleTouchEnabled = YES;
    self.helpButton = (UIButton *)[self.startView viewWithTag:12];
    [self.helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    self.textField = (UITextField *)[self.startView viewWithTag:13];
    self.textField.delegate = self;
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *clearImage = [UIImage imageNamed:@"edit-icon"];
    [editButton setImage:clearImage forState:UIControlStateNormal];
    // TODO create a subclass of UITextField to increase right padding
    [editButton setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [editButton setFrame:CGRectMake(0.0, 0.0, clearImage.size.width, clearImage.size.height)];
    [editButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    [self.textField setRightView:editButton];
    // We need a button of the same size left otherwise the text isn't centered (stupid apple)
    UIButton *spacerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [spacerButton setFrame:editButton.frame];
    self.textField.leftViewMode = UITextFieldViewModeUnlessEditing;
    self.textField.leftView = spacerButton;
    
    self.helpView = (UIView *)[self.startView viewWithTag:14];
    self.howToButton = (UIButton *)[self.startView viewWithTag:15];
    [self.howToButton addTarget:self action:@selector(showIntro) forControlEvents:UIControlEventTouchUpInside];
    self.aboutButton = (UIButton *)[self.startView viewWithTag:16];
    [self.aboutButton addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];
    self.closeHelpButton = (UIButton *)[self.startView viewWithTag:17];
    [self.closeHelpButton addTarget:self action:@selector(hideHelp) forControlEvents:UIControlEventTouchUpInside];
    
    self.standingView = [self loadSubViewFromNib:@"StandingView"];
    self.standingText = (UILabel *)[self.standingView viewWithTag:11];
    
    self.standingHoursL = (UILabel *)[self.standingView viewWithTag:12];
    self.standingHoursR = (UILabel *)[self.standingView viewWithTag:13];
    self.standingMinutesL = (UILabel *)[self.standingView viewWithTag:14];
    self.standingMinutesR = (UILabel *)[self.standingView viewWithTag:15];
    self.standingSecondsL = (UILabel *)[self.standingView viewWithTag:16];
    self.standingSecondsR = (UILabel *)[self.standingView viewWithTag:17];
    
    self.graceView = [self loadSubViewFromNib:@"GraceView"];
    self.graceButton = (UIImageView *)[self.graceView viewWithTag:11];
    self.graceButton.multipleTouchEnabled = YES;
    self.countdownLabel = (UILabel *)[self.graceView viewWithTag:13];
    self.doneButton = (UIButton *)[self.graceView viewWithTag:12];
    [self.doneButton addTarget:self action:@selector(enterStandingDoneState) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneView = [self loadSubViewFromNib:@"DoneView"];
    self.mapView = (MKMapView *)[self.doneView viewWithTag:16];
    self.doneText = (UILabel *)[self.doneView viewWithTag:12];
    self.shareButton = (UIButton *)[self.doneView viewWithTag:14];
    [self.shareButton addTarget:self action:@selector(openActivityViewController) forControlEvents:UIControlEventTouchUpInside];
    self.againButton = (UIButton *)[self.doneView viewWithTag:15];
    [self.againButton addTarget:self action:@selector(enterStandingBeforeState) forControlEvents:UIControlEventTouchUpInside];

    // Setup the textfield size and value
    CGFloat fontSize = self.textField.font.pointSize;
    [self.textField setFont:[UIFont fontWithName:@"JeanLuc-Bold" size:fontSize]];
    
    if (![self.standManager.message isEqualToString:@""]) {
        self.textField.text = self.standManager.message;
    }
    
    [self enterStandingBeforeState];
}

- (void)viewDidAppear:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowedIntro"]) {
        [self performSegueWithIdentifier:@"ShowIntro" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.standingState==StandingGraceMovement || self.standingState==StandingGraceTouch || self.standingState==StandingDone) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)enterStandingBeforeState {
    NSLog(@"Enter standing before state");
    
    self.standingState = StandingBefore;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // The help should be hidden for when we stand again
    [self hideHelp];
    
    [self setTimeOnViews:0];
    
    self.pauseSeconds = 0.0;
    
    self.standingState = StandingBefore;
    
    self.smoothX = 0.0;
    self.smoothY = 0.0;
    self.smoothZ = 0.0;
    
    [self showStartView];
}

- (void)startStanding {
    NSLog(@"Enter standing during state");
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Get location from StandManager
    NSLog(@"Got location back from store %f", self.standManager.coordinate.latitude);
    
    // Post it to our webservice
    NSDictionary *parameters = @{@"lat": [[NSNumber numberWithDouble:self.standManager.coordinate.latitude] stringValue], @"lon": [[NSNumber numberWithDouble:self.standManager.coordinate.longitude] stringValue], @"vendorid": [[[UIDevice currentDevice] identifierForVendor] UUIDString], @"message": self.standManager.message};
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:delegateQueue];
    
    self.requestOperation = [NSBlockOperation blockOperationWithBlock:^{}];
    
    // Going to touch this reference on self inside the block so need a weak reference
    __weak NSBlockOperation *weakBlockOp = self.requestOperation;
    
    NSOperation *firstOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Start first block");
        
        NSURL *url = [NSURL URLWithString:@"http://getstanding.com/catch"];
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
                
                self.standManager.secret = [json objectForKey:@"secret"];
                self.standManager.sessionid = [[json objectForKey:@"sessionid"] intValue];
                
                // Reset these to reasonable defaults
                self.standManager.duration = 0;
                
                NSLog(@"Finishing first request");
            }];
            
            [self.urlSession.delegateQueue addOperation:self.requestOperation];
        }];
        
        [postDataTask resume];
        
        NSLog(@"Finish first block");
    }];
    
    [self.urlSession.delegateQueue addOperation:firstOperation];
    
    
    if (nil == self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    
    self.startTime = [[NSDate alloc] init];
    
    self.secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTime) userInfo:nil repeats:YES];
    
    self.motionManager.deviceMotionUpdateInterval = 1/15.0;
    
    if (self.motionManager.deviceMotionAvailable) {
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            
            CMAcceleration userAcceleration = motion.userAcceleration;
            
            double RC = 0.4;
            double alpha = 1/15.0 / (RC + 1/15.0);
            
            self.smoothX = (alpha * ABS(userAcceleration.x)) + (1.0 - alpha) * self.smoothX;
            self.smoothY = (alpha * ABS(userAcceleration.y)) + (1.0 - alpha) * self.smoothY;
            self.smoothZ = (alpha * ABS(userAcceleration.z)) + (1.0 - alpha) * self.smoothZ;

//            NSLog(@"Smooth motion: %.2f, %.2f, %.2f", smoothX, smoothY, smoothZ);
            
            double smoothSum = self.smoothX + self.smoothY + self.smoothZ;
            
            if (smoothSum > 0.2) {
                // Done standing, you did a step
                
                // This can also happen during StandingGraceTouch so invalidate the timer
//                if (graceTimer) {
//                    [graceTimer invalidate];
//                }
//                
//                [self enterStandingDoneState];
            } else if (self.standingState == StandingDuring && smoothSum > 0.14) {
                // Show the grace view for too much movement
                
                [self enterStandingGraceMovementState];
                
                NSLog(@"Quit moving so much");
                
            } else if (self.standingState == StandingGraceMovement && smoothSum <= 0.1) {
                // Stop showing the grace view because movement is within parameters again
                
                // But wait for at least one second
                NSDate *now = [[NSDate alloc] init];
                NSTimeInterval graceInterval = [now timeIntervalSinceDate:self.graceStart];
                
                if ((int) graceInterval > 1.0) {
                    [self enterStandingDuringState];
                }
            }
        }];
    }
    
    [self enterStandingDuringState];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // We only respond to touches if the user is not typing any text at the moment
    if (self.standingState != DontAllowStart) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self.startButton];
            
            NSLog(@"Touch at %f %f", location.x, location.y);
            
            if (location.x > 0.0 && location.x < self.startButton.frame.size.width && location.y > 0.0 && location.y < self.startButton.frame.size.height) {
                NSLog(@"Qualifies");
                [self.currentTouches addObject:touch];
            }
        }
        
        if ([self.currentTouches count] > 0) {
            if (self.standingState==StandingBefore) {
                [self startStanding];
            } else if (self.standingState == StandingGraceTouch) {
                [self enterStandingDuringState];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self.currentTouches removeObject:touch];
    }
    
    if ([self.currentTouches count] == 0) {
        if (self.standingState == StandingDuring || self.standingState == StandingGraceMovement) {
            [self enterStandingGraceTouchState];
        }
    }
}

- (void)incrementTime {
    self.endTime = [[NSDate alloc] init];
    
    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
    
    // Update duration in our shared object
    self.standManager.duration = (int)(interval - self.pauseSeconds);
    
    [self setTimeOnViews:interval-self.pauseSeconds];
    
    if (self.standingState == StandingDuring) {
        if ((int)interval % 60 /*240*/ == 0) {
            // Send a keep alive to the server every minute with data about the time
            NSLog(@"Sending keep alive");
            
            NSDictionary *parameters = @{@"secret": self.standManager.secret, @"sessionid": [NSNumber numberWithInt:self.standManager.sessionid]};
            
            NSURL *url = [NSURL URLWithString:@"http://getstanding.com/live"];
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
        
//        NSLog(@"Time increment normal %d", (int)interval);
    }
}

- (void)incrementGraceTime {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    NSDate *now = [[NSDate alloc] init];
    
    NSTimeInterval interval = [now timeIntervalSinceDate:self.graceStart];
    
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", 5-(int)interval];
    
    self.pauseSeconds += 1.0;
    
    NSLog(@"Increment grace time %d", (int)interval);
    
    if ((int)interval > 4) {
        [self enterStandingDoneState];
    }
}

- (void)setTimeOnViews:(NSTimeInterval)interval {
    int hours = (int)interval / (60 * 60);
    int minutes = ((int)interval - (hours * 60 * 60)) / 60;
    int seconds = (int)interval - (hours * 60 * 60) - (minutes * 60);
    
    self.standingHoursL.text = [NSString stringWithFormat:@"%d", hours / 10];
    self.standingHoursR.text = [NSString stringWithFormat:@"%d", hours % 10];
    
    self.standingMinutesL.text = [NSString stringWithFormat:@"%d", minutes / 10];
    self.standingMinutesR.text = [NSString stringWithFormat:@"%d", minutes % 10];
    
    self.standingSecondsL.text = [NSString stringWithFormat:@"%d", seconds / 10];
    self.standingSecondsR.text = [NSString stringWithFormat:@"%d", seconds % 10];
    
    self.doneText.text = [NSString stringWithFormat:@"%@ for\n%@.", [self.standManager getDurationStringWithBreaks], self.standManager.message];
}

- (void)enterStandingDuringState {
    NSLog(@"Enter standing during state");
    
    self.standingState = StandingDuring;
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.standingText.text = [NSString stringWithFormat:@"You are standing \nfor %@", self.standManager.message];
    
    if (self.graceTimer) {
        [self.graceTimer invalidate];
    }
    
    [self showStandingView];
}

- (void)enterStandingDoneState {
    NSLog(@"Enter standing done state");
    
    self.standingState = StandingDone;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // If there was a grace timer running, invalidate it
    [self.graceTimer invalidate];
    
    [self showDoneView];
    
    // Move the legal link in the map
    UILabel *legalLabel = [self.mapView.subviews objectAtIndex:1];
    legalLabel.center = CGPointMake(self.mapView.frame.size.width - legalLabel.center.x, legalLabel.center.y);
    
    
    if (self.standManager.secret) {
        // If we don't have this the first request failed and we should not be doing this
        
        NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"Starting second block");
            
            NSDictionary *parameters = @{@"secret": self.standManager.secret, @"sessionid": [NSNumber numberWithInt:self.standManager.sessionid], @"duration": [NSNumber numberWithInt:self.standManager.duration]};
            
            NSURL *url = [NSURL URLWithString:@"http://getstanding.com/done"];
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
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection failure" message:@"Because of a failure with your internet connection we have not been able to save your session. Our apologies." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [message show];
    }
    
    
    [self.motionManager stopDeviceMotionUpdates];
    [self.secondTimer invalidate];
}

- (void)enterStandingGraceTouchState {
    NSLog(@"Enter standing grace touch state");
    
    self.standingState = StandingGraceTouch;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Reset the counter on the grace countdown
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", 5];
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

    self.graceStart = [[NSDate alloc] init];
    
    [self.graceTimer invalidate];
    self.graceTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementGraceTime) userInfo:nil repeats:YES];
    
    [self showGraceView];
}

// TODO mostly the same method as the above
- (void)enterStandingGraceMovementState {
    NSLog(@"Enter standing grace movement state");
    
    self.standingState = StandingGraceMovement;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Reset the counter on the grace countdown
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", 5];
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    self.graceStart = [[NSDate alloc] init];
    
    [self.graceTimer invalidate];
    self.graceTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementGraceTime) userInfo:nil repeats:YES];
    
    [self showGraceView];
}

- (void)showHelp {
    self.helpView.hidden = NO;
    self.helpView.alpha = 0.0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.helpView.alpha = 1.0;
    } completion:nil];
}

- (void)showAbout {
    [self performSegueWithIdentifier:@"ShowAbout" sender:self];
    [self hideHelp];
}

- (void)showIntro {
    [self performSegueWithIdentifier:@"ShowIntro" sender:self];
    [self hideHelp];
}

- (void)hideHelp {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.helpView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.helpView.hidden = YES;
    }];
}

- (void)clearButtonPressed {
//    self.textField.userInteractionEnabled = YES;
    [self.textField becomeFirstResponder];
}

- (void)openActivityViewController {
    NSString *text = [NSString stringWithFormat:@"I stood %@ for %@ with @getstanding", [self.standManager getDurationString], self.textField.text];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://getstanding.com/s/%d", self.standManager.sessionid]];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[text, url] applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeAddToReadingList];
    
    [[self navigationController] presentViewController:avc animated:YES completion:nil];
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
    self.standManager.coordinate = self.currentLocation.coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.standManager.coordinate, 1000, 1000);
    [self.mapView setRegion:region];
}

# pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // This limits the text in the topic field
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 66 || returnKey;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.standingState = DontAllowStart;
    
    textField.text = @"";
    
    textField.rightView.hidden = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.text = self.standManager.message;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.rightView.hidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    
    self.standingState = StandingBefore;
    
    self.standManager.message = self.textField.text;
    
    return YES;
}

@end
