//
//  TextFeildWithCell.m
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell
@synthesize textField,addButton,isAddButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        textField = [[UITextField alloc] init];
        [addButton setHidden:YES];
        [self addSubview:addButton];
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
