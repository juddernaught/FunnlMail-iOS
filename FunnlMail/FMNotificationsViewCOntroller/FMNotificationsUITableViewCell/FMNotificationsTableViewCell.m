//
//  FMNotificationsTableViewCell.m
//  FunnlMail
//
//  Created by shrinivas on 09/10/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FMNotificationsTableViewCell.h"

@implementation FMNotificationsTableViewCell
@synthesize notificationSwitch,funnelName;

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    int height = 20;
    int width = 40;
    notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 20 - width, 7, width, height)];
    [self addSubview:notificationSwitch];
    funnelName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, WIDTH - 20 - width - 20, 40)];
    [funnelName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    [funnelName setTextColor:[UIColor blackColor]];
    funnelName.lineBreakMode = NSLineBreakByTruncatingTail;
    funnelName.numberOfLines = 1;
    [funnelName setBackgroundColor:[UIColor clearColor]];
    [funnelName setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:funnelName];
  }
  return self;
}

- (void)setTextToLabel:(NSString *)text {
  funnelName.text = text;
}

- (void)setBoolForSwitch:(BOOL)flag {
  [notificationSwitch setOn:flag];
}

- (void)setTagForSwitch:(int)tag {
  notificationSwitch.tag = tag;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
