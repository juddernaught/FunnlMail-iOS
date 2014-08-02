//
//  TextFeildWithCell.h
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell

@property(nonatomic,retain) UITextField *textField;
@property(nonatomic,retain) UIButton *addButton;
@property(nonatomic,assign) BOOL isAddButton;
@property(nonatomic,assign) BOOL isSwitchVisibleMode;
@property(nonatomic,retain) UISwitch *switchButton;
@end
