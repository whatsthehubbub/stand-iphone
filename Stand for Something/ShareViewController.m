//
//  ShareViewController.m
//  Stand for Something
//
//  Created by Alper Cugun on 12/2/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

@synthesize textField;
@synthesize timeLabel;
@synthesize URLLabel;

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
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 30.0f)];
    [clearButton setImage:[UIImage imageNamed:@"05-button-close"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"05-button-close"] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
    self.textField.rightView = clearButton;
    self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    self.timeLabel.text = [NSString stringWithFormat:@"Share that you stood %@ for", [standManager getDurationString]];
    
    self.URLLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.URLLabel.delegate = self;
    self.URLLabel.text = [NSString stringWithFormat:@"http://standforsomething.herokuapp.com/stand/%d", standManager.sessionid];
    
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

- (IBAction)tweetResult:(id)sender {
    // TODO do this check on viewDidLoad and modify UI according to service availability
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *slvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];

        [slvc setInitialText:[NSString stringWithFormat:@"I stood %@ for %@.", [standManager getDurationString], textField.text]];
        
        // TODO test adding the URL
        [slvc addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://standforsomething.herokuapp.com/stand/%d", standManager.sessionid]]];
        
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
    NSURL *url = [NSURL URLWithString:@"http://standforsomething.herokuapp.com/done"];
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

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

@end
