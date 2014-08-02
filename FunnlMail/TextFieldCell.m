//
//  TextFeildWithCell.m
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell
@synthesize textField,addButton,isAddButton,cancelButton,switchButton;

-(void) setIsSwitchVisibleMode:(BOOL)isSwitchVisibleMode
{
    addButton.hidden = isSwitchVisibleMode;
    cancelButton.hidden = isSwitchVisibleMode;
    textField.hidden = isSwitchVisibleMode;
    switchButton.hidden = !isSwitchVisibleMode;
}


-(BOOL) isSwitchVisibleMode
{
    return addButton.hidden;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        textField = [[UITextField alloc] init];
        switchButton = [[UISwitch alloc] init];
        [addButton setHidden:YES];
        [cancelButton setHidden:YES];
        [self addSubview:addButton];
        [self addSubview:cancelButton];
        [self addSubview:textField];
        [self setAccessoryView:switchButton];
        [switchButton setHidden:YES];
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
