//
//  TextFeildWithCell.m
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell
@synthesize textField,addButton,isAddButton,cancelButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        textField = [[UITextField alloc] init];
        [addButton setHidden:YES];
        [cancelButton setHidden:YES];
        [self addSubview:addButton];
        [self addSubview:cancelButton];
        [self addSubview:textField];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
