//
//  ShareViewController.m
//  Stand for Something
//
//  Created by Alper Cugun on 12/2/14.
//  Copyright (c) 2014 Hubbub. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

@synthesize textField;
@synthesize timeLabel;

@synthesize standManager;

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
    standManager = [StandManager sharedManager];
    
    CGFloat fontSize = self.textField.font.pointSize;
    [self.textField setFont:[UIFont fontWithName:@"ChunkFive" size:fontSize]];
    
    self.textField.text = standManager.message;
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 40.0f)];
    [clearButton setImage:[UIImage imageNamed:@"05-button-clear"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"05-button-clear"] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
    self.textField.rightView = clearButton;
    self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    self.timeLabel.text = [NSString stringWithFormat:@"Share that\nyou stood\n%@ for", [standManager getDurationString]];
    
    // TODO think about dismissing keyboard
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(doneWithText:)];
//    tap.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * Override status bar style in a couple of places.
 */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)openLink {
    NSString *urlString = [NSString stringWithFormat:@"http://getstanding.com/s/%d", standManager.sessionid];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)tweetResult:(id)sender {
    // TODO do this check on viewDidLoad and modify UI according to service availability
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *slvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];

        [slvc setInitialText:[NSString stringWithFormat:@"I stood %@ for %@ with @getstanding", [standManager getDurationString], textField.text]];
        
        // TODO test adding the URL
        [slvc addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://getstanding.com/s/%d", standManager.sessionid]]];
        
        [slvc setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultDone:
                    NSLog(@"posted tweet");
                    
                    break;
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Cancelled tweet");
                    
                    break;
                default:
                    break;
            }
            
        }];
        
        [self presentViewController:slvc animated:YES completion:nil];
    }
}

- (void)clearText {
    self.textField.text = @"";
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneWithText:(id)sender {
    [self.textField resignFirstResponder];
    
    standManager.message = self.textField.text;
    
    // Update website with the time
    NSDictionary *parameters = @{@"secret": standManager.secret, @"sessionid": [NSNumber numberWithInt:standManager.sessionid], @"message": self.textField.text};
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"http://getstanding.com/done"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[parameters urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError = nil;
        NSDictionary *json = nil;
        json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        
        NSLog(@"Server response %@", json);
    }];
    
    [postDataTask resume];
}

# pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 66 || returnKey;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @"";
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.text = @"something";
    }
    
    return YES;
}

@end
