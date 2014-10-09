//
//  FMNotificationsTableViewCell.h
//  FunnlMail
//
//  Created by shrinivas on 09/10/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMNotificationsTableViewCell : UITableViewCell
{
  UILabel *funnelName;
}
@property (nonatomic, strong) UILabel *funnelName;
@property (nonatomic, strong) UISwitch *notificationSwitch;
- (void)setTextToLabel:(NSString *)text;
- (void)setBoolForSwitch:(BOOL)flag;
- (void)setTagForSwitch:(int)tag;
@end
