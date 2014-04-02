//
//  IntroViewController.m
//  Stand for Something
//
//  Created by Alper Cugun on 2/4/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

@synthesize scrollView;

@synthesize progressImage;

@synthesize view1;
@synthesize view2;
@synthesize view3;


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
    
    self.view1.frame = CGRectMake(0, 0, 320, self.scrollView.frame.size.height);
    self.view2.frame = CGRectMake(320, 0, 320, self.scrollView.frame.size.height);
    self.view3.frame = CGRectMake(640, 0, 320, self.scrollView.frame.size.height);
    
    scrollView.contentSize = CGSizeMake(320 * 3, 568);
    
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowedIntro"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = ((int)scrollView.contentOffset.x / 320) + 1;
    
    NSString *imageString = [NSString stringWithFormat:@"07-dots-0%d", page];
    
    NSLog(imageString);
    
    self.progressImage.image = [UIImage imageNamed:imageString];
}

@end
