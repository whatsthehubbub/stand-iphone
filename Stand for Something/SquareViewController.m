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

@end
