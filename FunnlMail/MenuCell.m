//
//  ZenMenuCell.m
//  Zen
//
//  Created by macbook on 4/28/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell
@synthesize menuImage,menuLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 150, 44)];
        menuLabel.font = NORMAL_FONT_L;
        [self.contentView addSubview:menuLabel];
        menuLabel.highlightedTextColor = UIColorFromRGB(0x1B8EEE);
 
        menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 28, 28)];
        menuImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:menuImage];
        
        UILabel *sepLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 44, 320, 1)];
        sepLabel.backgroundColor = WHITE_CLR;
        [self.contentView addSubview:sepLabel];
                
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
