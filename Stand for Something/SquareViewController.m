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
    
    NSLog(@"loaded view for plaza %@", [plaza objectForKey:@"name"]);
    
    [self setTitle:[plaza objectForKey:@"name"]];
    
//    NSLog(@"getting the coord? %@", [plaza objectForKey:@"location"]);

    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake([[[plaza objectForKey:@"location"] objectForKey:@"lat"] doubleValue], [[[plaza objectForKey:@"location"] objectForKey:@"lng"] doubleValue]);
    
    NSLog(@"creating location value %f, %f", mapCenter.latitude, mapCenter.longitude);
    //[self.mapView setCenterCoordinate:mapCenter animated:YES];
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(mapCenter, 100, 100)];
    [self.mapView setRegion:adjustedRegion animated:YES];
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
    
    motionManager.deviceMotionUpdateInterval = 1/15.0;
    
    if (motionManager.deviceMotionAvailable) {
        NSLog(@"Device motion available");
        
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            
            CMAcceleration userAcceleration = motion.userAcceleration;
            
            maxX = MAX(ABS(maxX), ABS(userAcceleration.x));
            maxY = MAX(ABS(maxY), ABS(userAcceleration.y));
            maxZ = MAX(ABS(maxZ), ABS(userAcceleration.z));
            
            self.motionLabel.text = [NSString stringWithFormat:@"Current: %f,%f,%f\nMax: %f,%f,%f", userAcceleration.x, userAcceleration.y, userAcceleration.z, maxX, maxY, maxZ];
            
//            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motionManager waitUntilDone:YES];
        }];
    }
}

- (IBAction)reset:(id)sender {
    self.maxX = 0.0;
    self.maxY = 0.0;
    self.maxZ = 0.0;
}

//- (void)handleDeviceMotion:(CMDeviceMotion *)motion {
//    
//}

@end
