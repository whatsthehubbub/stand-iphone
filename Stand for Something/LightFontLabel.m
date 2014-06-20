//
//  FontLabel.m
//  Stand for Something
//
//  Created by Alper Cugun on 29/8/13.
//  Copyright (c) 2014 Hubbub. All rights reserved.
//

#import "FontLabel.h"

@implementation FontLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFontStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setFontStyle];
    }
    
    return self;
}

- (void)setFontStyle {
    CGFloat fontSize = self.font.pointSize;
    
    [self setFont:[UIFont fontWithName:@"JeanLuc-Thin" size:fontSize]];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
