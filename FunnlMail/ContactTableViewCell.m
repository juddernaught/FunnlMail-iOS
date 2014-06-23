//
//  ContactTableViewCell.m
//  FunnlMail
//
//  Created by iauro001 on 6/23/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell
@synthesize nameLabel,contactImage,flag,selectionIndicator;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        contactImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
        [contactImage setBackgroundColor:[UIColor clearColor]];
        selectionIndicator = [[UIView alloc] initWithFrame:CGRectMake(280-10-20, 20, 20, 20)];
        selectionIndicator.clipsToBounds = YES;
        selectionIndicator.layer.cornerRadius = 10.0f;
        selectionIndicator.layer.borderWidth = 0.5f;
        selectionIndicator.layer.borderColor = [[UIColor blackColor] CGColor];
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 280 - 70 - 30 - 5, 60)];
        nameLabel.numberOfLines = 2;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:contactImage];
        [self.contentView addSubview:selectionIndicator];
        [self.contentView addSubview:nameLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
//    self.flag = FALSE;
//    self.nameLabel.text = @"";
}

@end
