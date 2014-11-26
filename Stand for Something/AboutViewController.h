//
//  AboutViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 27/2/14.
//  Copyright (c) 2014 Hubbub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface AboutViewController : UIViewController

@property (strong) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *aboutContent;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end
