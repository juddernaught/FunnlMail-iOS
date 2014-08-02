//
//  TextFeildWithCell.m
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell
@synthesize textField,addButton,isAddButton,switchButton;

-(void) setIsSwitchVisibleMode:(BOOL)isSwitchVisibleMode
{
    textField.hidden = isSwitchVisibleMode;
    [self setAccessoryView:textField.hidden ? switchButton : addButton];
}


-(BOOL) isSwitchVisibleMode
{
    return textField.hidden;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        textField = [[UITextField alloc] init];
        switchButton = [[UISwitch alloc] init];
        addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [self addSubview:textField];
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    textField.frame = CGRectMake(10, 2,250, 40);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
