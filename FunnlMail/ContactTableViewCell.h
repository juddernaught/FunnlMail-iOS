//
//  ContactTableViewCell.h
//  FunnlMail
//
//  Created by iauro001 on 6/23/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell
{

}
@property (retain, nonatomic)UILabel *nameLabel;
@property (retain, nonatomic)UIImageView *contactImage;
@property (retain, nonatomic)UIView *selectionIndicator;
@property BOOL flag;
@end
