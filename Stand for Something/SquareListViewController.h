//
//  SquareListViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 20/7/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "FSNConnection.h"
#import "SquareViewController.h"

@interface SquareListViewController : UITableViewController <CLLocationManagerDelegate>

@property (strong) CLLocationManager *locationManager;

@property (strong) NSArray *plazas;

@end
