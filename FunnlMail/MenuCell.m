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
        
        menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 150, 44)];
        menuLabel.font = NORMAL_FONT_M2;
        [self.contentView addSubview:menuLabel];
        menuLabel.highlightedTextColor = UIColorFromRGB(0x1B8EEE);
 
        menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 20, 20)];
        menuImage.contentMode = UIViewContentModeScaleAspectFit;
        menuImage.userInteractionEnabled = YES;
        [self.contentView addSubview:menuImage];
        
//        UILabel *sepLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 44, 320, 1)];
//        sepLabel.backgroundColor = WHITE_CLR;
//        [self.contentView addSubview:sepLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
