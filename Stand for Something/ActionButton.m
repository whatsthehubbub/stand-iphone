//
//  ActionButton.m
//  Stand for Something
//
//  Created by Alper Cugun on 29/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import "ActionButton.h"

@implementation ActionButton

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
    [self.titleLabel setFont:[UIFont fontWithName:@"ChunkFive" size:24.0]];
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
