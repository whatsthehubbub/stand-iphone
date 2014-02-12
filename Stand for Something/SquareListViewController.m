//
//  SquareListViewController.m
//  Stand for Something
//
//  Created by Alper Cugun on 20/7/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import "SquareListViewController.h"

@interface SquareListViewController ()

@end

@implementation SquareListViewController

@synthesize locationManager;

@synthesize currentLocation;

@synthesize plazas;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self performSegueWithIdentifier:@"Stand" sender:self];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 200;
    
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"ToSquare"]) {
//
//    }
//}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [locations lastObject];
    
    NSLog(@"Get location %f x %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    // Store the current location in our model
//    StandManager *standManager = [StandManager sharedManager];
//    standManager.location = self.currentLocation.coordinate;
    
    
    
    NSURL *url = [NSURL URLWithString:@"https://api.foursquare.com/v2/venues/search"];
    NSDictionary *headers = [NSDictionary dictionary];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"E5OLRBH2Z2KW2BHD43V2YTKDTFMUCIPQHBAIULUJDEPEUW05", @"client_id", @"TXJOYFAXMANGKMJKFSERSJDOX0DPZMM5MOUT23K241DCSEJK", @"client_secret", @"20130719", @"v", [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude], @"ll", @"4bf58dd8d48988d164941735,4bf58dd8d48988d163941735", @"categoryId", @"1000", @"radius", nil];
    
    FSNConnection *conn = [FSNConnection withUrl:url method:FSNRequestMethodGET headers:headers parameters:parameters parseBlock:^id(FSNConnection *c, NSError **error) {
        
        return [c.responseData dictionaryFromJSONWithError:error];
    } completionBlock:^(FSNConnection *c) {
        //        NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
        
        NSDictionary *result = (NSDictionary *)c.parseResult;
        self.plazas = [[result objectForKey:@"response"] objectForKey:@"venues"];
        
//        NSLog(@"plazas got %@", self.plazas);
        
        
        [self.tableView reloadData];
        
    } progressBlock:^(FSNConnection *c) {
//        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
    }];
    
    //    NSLog(@"request %@", conn);
    
    [conn start];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.plazas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SquareCell";
    SquareTableViewCell *cell = (SquareTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *plaza = [self.plazas objectAtIndex:indexPath.row];
    
    CLLocationCoordinate2D plazaCenter = CLLocationCoordinate2DMake([[[plaza objectForKey:@"location"] objectForKey:@"lat"] doubleValue], [[[plaza objectForKey:@"location"] objectForKey:@"lng"] doubleValue]);
    CLLocation *plazaLocation = [[CLLocation alloc] initWithCoordinate:plazaCenter altitude:1 horizontalAccuracy:1 verticalAccuracy:1 timestamp:nil];
    CLLocationDistance meters = [self.currentLocation distanceFromLocation:plazaLocation];
    
    cell.nameLabel.text = [plaza objectForKey:@"name"];
    cell.addressLabel.text = [NSString stringWithFormat:@"%@ (%d meters)", [[plaza objectForKey:@"location"] objectForKey:@"address"], (int)meters];
    
    cell.numberOfPeople.text = [NSString stringWithFormat:@"%d", arc4random_uniform(12)];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *plaza = [self.plazas objectAtIndex:indexPath.row];
    
    SquareViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SquareViewController"];
    
    svc.plaza = plaza;
    
    [self.navigationController pushViewController:svc animated:YES];
}

@end
