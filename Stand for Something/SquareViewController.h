//
//  SquareViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 3/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>

@interface SquareViewController : UIViewController

@property (strong) NSDictionary *plaza;

@property (strong) IBOutlet MKMapView *mapView;
@property (strong) IBOutlet UILabel *motionLabel;

@property (strong) CMMotionManager *motionManager;

@property (assign) double maxX;
@property (assign) double maxY;
@property (assign) double maxZ;

- (IBAction)startStanding:(id)sender;
- (IBAction)reset:(id)sender;

@end
