//
//  RightViewMarginTextField.m
//  Stand for Something
//
//  Created by Alper Cugun on 22/7/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import "RightViewMarginTextField.h"

@implementation RightViewMarginTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super rightViewRectForBounds:bounds];
    
    rect.origin.x -= 10.0;
    
    return rect;
}

@end
