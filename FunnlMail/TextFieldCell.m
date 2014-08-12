//
//  TextFeildWithCell.m
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell
@synthesize textField,addButton,isAddButton,switchButton,thumbnailImageView,tapButton;

-(void) setIsSwitchVisibleMode:(BOOL)isSwitchVisibleMode
{
    textField.hidden = isSwitchVisibleMode;
    addButton.hidden = isSwitchVisibleMode;
    switchButton.hidden = !isSwitchVisibleMode;
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
        textField.textColor = WHITE_CLR;
        switchButton = [[UISwitch alloc] init];
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(0, 0, 25.f, 25.f);
        tapButton = [[UIButton alloc] initWithFrame:CGRectMake(55, 0, 250 - 55, 44)];
//        [tapButton setBackgroundColor:[UIColor redColor]];
        thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 2, 40, 40)];
        thumbnailImageView.clipsToBounds = YES;
        thumbnailImageView.layer.cornerRadius = 20;
        [self addSubview:textField];
        [self addSubview:thumbnailImageView];
        [self addSubview:tapButton];
        
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
//    textField.frame = CGRectMake(55, 2,250 - 45, 40);
//    textField.frame = CGRectMake(10, 2, 250, 40);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
