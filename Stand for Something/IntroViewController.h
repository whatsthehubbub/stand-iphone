//
//  IntroViewController.h
//  Stand for Something
//
//  Created by Alper Cugun on 2/4/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController <UIScrollViewDelegate>

@property (strong) IBOutlet UIScrollView *scrollView;
@property (strong) IBOutlet UIImageView *progressImage;

@property (strong) IBOutlet UIView *view1;
@property (strong) IBOutlet UIView *view2;
@property (strong) IBOutlet UIView *view3;

@end
