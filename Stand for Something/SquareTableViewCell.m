    //
//  SquareTableViewCell.m
//  Stand for Something
//
//  Created by Alper Cugun on 29/8/13.
//  Copyright (c) 2013 Alper Cugun. All rights reserved.
//

#import "SquareTableViewCell.h"

@implementation SquareTableViewCell

@synthesize nameLabel;
@synthesize addressLabel;

@synthesize numberOfPeople;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"init squaretableviewcell");
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
