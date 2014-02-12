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
    
    CGFloat fontSize = self.textField.font.pointSize;
    [self.textField setFont:[UIFont fontWithName:@"ChunkFive" size:fontSize]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tweetResult {
    NSLog(@"Tweeting the result");
    
    // TODO do this check on viewDidLoad and modify UI according to service availability
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *slvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [slvc setInitialText:@"I stood for something."];
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

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    
    return NO;
}

@end
