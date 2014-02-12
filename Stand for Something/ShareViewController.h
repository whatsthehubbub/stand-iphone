//
//  ShareViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 12/2/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface ShareViewController : UIViewController <UITextFieldDelegate>

@property (strong) UITextField *textField;

- (IBAction)closeButton:(id)sender;

@end
