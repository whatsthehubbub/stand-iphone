//
//  ShareViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 12/2/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

#import "StandManager.h"
#import "TTTAttributedLabel.h"
#import "NSDictionary+URLEncoding.h"

@interface ShareViewController : UIViewController <UITextFieldDelegate, TTTAttributedLabelDelegate>

@property (strong) IBOutlet UITextField *textField;
@property (strong) IBOutlet UILabel *timeLabel;
@property (strong) IBOutlet TTTAttributedLabel *URLLabel;

@property (strong) StandManager *standManager;

- (IBAction)closeButton:(id)sender;

@end
