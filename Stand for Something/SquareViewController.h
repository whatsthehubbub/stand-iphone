//
//  SquareViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 3/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface SquareViewController : UIViewController <MKMapViewDelegate>

@property (strong) NSDictionary *plaza;

@property (strong) IBOutlet MKMapView *mapView;

- (IBAction)startStanding:(id)sender;
- (IBAction)back:(id)sender;

@end
