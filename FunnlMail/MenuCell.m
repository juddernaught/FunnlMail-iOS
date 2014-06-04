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
        
        if(INTERFACE_IS_PAD){
            menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 300, 100)];
            menuLabel.font = NORMAL_FONT_XL;
            [self.contentView addSubview:menuLabel];
            
            menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 20, 60, 60)];
            menuImage.contentMode = UIViewContentModeCenter;
            [self.contentView addSubview:menuImage];
            
        }else{
            menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 150, 44)];
            menuLabel.font = NORMAL_FONT_L;
            [self.contentView addSubview:menuLabel];
            
            menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2, 15, 15)];
            menuImage.contentMode = UIViewContentModeCenter;
            [self.contentView addSubview:menuImage];

        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
