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

@synthesize headerLabel;
@synthesize mapView;

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
    
    self.headerLabel.text = [plaza objectForKey:@"name"];
}

- (void)viewDidAppear:(BOOL)animated {
    // Fuck, map changes need to be done in viewDidAppear
    
    NSLog(@"getting the coord? %@", [plaza objectForKey:@"location"]);
    
    CLLocationCoordinate2D plazaCenter = CLLocationCoordinate2DMake([[[plaza objectForKey:@"location"] objectForKey:@"lat"] doubleValue], [[[plaza objectForKey:@"location"] objectForKey:@"lng"] doubleValue]);
    
    NSLog(@"creating location value %f, %f", plazaCenter.latitude, plazaCenter.longitude);
    
    MKCoordinateRegion originalRegion = MKCoordinateRegionMakeWithDistance(plazaCenter, 1000, 1000);
    
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
    [self performSegueWithIdentifier:@"Stand" sender:sender];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"Region changed");
}

@end
