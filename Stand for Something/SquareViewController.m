//
//  SquareViewController.m
//  Stand for Something
//
//  Created by Alper Cugun on 3/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import "SquareViewController.h"

@interface SquareViewController ()

@end

@implementation SquareViewController

@synthesize plaza;

@synthesize mapView;
@synthesize motionLabel;

@synthesize motionManager;

@synthesize maxX;
@synthesize maxY;
@synthesize maxZ;

@synthesize startTime;
@synthesize endTime;
@synthesize secondTimer;

@synthesize timeLabel;

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
    
//    NSLog(@"loaded view for plaza %@", [plaza objectForKey:@"name"]);
    
    [self setTitle:[plaza objectForKey:@"name"]];
}

- (void)viewDidAppear:(BOOL)animated {
    // Fuck, map changes need to be done in viewDidAppear
    
    NSLog(@"getting the coord? %@", [plaza objectForKey:@"location"]);
    
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake([[[plaza objectForKey:@"location"] objectForKey:@"lat"] doubleValue], [[[plaza objectForKey:@"location"] objectForKey:@"lng"] doubleValue]);
    
    NSLog(@"creating location value %f, %f", mapCenter.latitude, mapCenter.longitude);
    
    MKCoordinateRegion originalRegion = MKCoordinateRegionMakeWithDistance(mapCenter, 1000, 1000);
    
    NSLog(@"Adjusted region %f x %f (%f %f)", originalRegion.center.latitude, originalRegion.center.longitude, originalRegion.span.latitudeDelta, originalRegion.span.longitudeDelta);
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:originalRegion];
    
    NSLog(@"Adjusted region %f x %f (%f %f)", adjustedRegion.center.latitude, adjustedRegion.center.longitude, adjustedRegion.span.latitudeDelta, adjustedRegion.span.longitudeDelta);
    
    [self.mapView setRegion:adjustedRegion animated:NO];
//    [self.mapView setCenterCoordinate:originalRegion.center animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startStanding:(id)sender {
    NSLog(@"Start standing");
    
    if (nil == motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    
    self.startTime = [[NSDate alloc] init];
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
            }
            
//            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motionManager waitUntilDone:YES];
        }];
    }
}

- (void)incrementTime {
    self.endTime = [[NSDate alloc] init];
    
    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%d seconds", (int)interval];
}

- (void)stopStanding {
    [self.motionManager stopDeviceMotionUpdates];
    [self.secondTimer invalidate];
    
    NSTimeInterval interval = [self.endTime timeIntervalSinceDate:self.startTime];
    self.timeLabel.text = [NSString stringWithFormat:@"Done standing! Time: %d seconds", (int)interval];
}

- (IBAction)reset:(id)sender {
    self.maxX = 0.0;
    self.maxY = 0.0;
    self.maxZ = 0.0;
}

# pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"Region changed");
}

@end
