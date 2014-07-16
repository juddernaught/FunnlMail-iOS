//
//  MainFilterCell.m
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MainFilterCell.h"
#import "View+MASAdditions.h"
#import "UIColor+HexString.h"
#import "MASConstraintMaker.h"

@implementation MainFilterCell
@synthesize notificationButton,settingsButton,mailImageView,messageCountLabel,shareButton;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithHexString:@"#E0E0EB"];
      
        coloredBarView = [[UIView alloc] init];
        coloredBarView.backgroundColor = self.barColor;
        [self addSubview:coloredBarView];
      
        [coloredBarView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.mas_top).with.offset(0);
          make.left.equalTo(self.mas_left).with.offset(0);
          make.width.equalTo(self.mas_width).with.offset(0);
        }];
      
        // need to figure out how to do this with Masonry
        NSLayoutConstraint *constraint = [NSLayoutConstraint
                                          constraintWithItem:coloredBarView
                                          attribute: NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:coloredBarView
                                          attribute:NSLayoutAttributeHeight
                                          multiplier:0
                                          constant:10];
      
        [self addConstraint:constraint];
      
        self.barColor = [UIColor redColor];
      
        filterTitleLabel = [[UILabel alloc] init];
        [filterTitleLabel setFont:[UIFont systemFontOfSize:18]];
        filterTitleLabel.textAlignment = NSTextAlignmentCenter;
        filterTitleLabel.text = @"Primary";
        //filterTitleLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:filterTitleLabel];
      
        [filterTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(coloredBarView.mas_bottom).with.offset(5);
          make.left.equalTo(coloredBarView.mas_left).with.offset(0);
          make.width.equalTo(coloredBarView.mas_width).with.offset(0);
        }];
      
        constraint = [NSLayoutConstraint
                      constraintWithItem:filterTitleLabel
                      attribute: NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:filterTitleLabel
                      attribute:NSLayoutAttributeHeight
                      multiplier:0
                      constant:25];
      
        [self addConstraint:constraint];
      
        mailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mail"]];
        mailImageView.frame = CGRectMake(0, 0, 29, 23);
        [self addSubview:mailImageView];
      
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(5 + 2, self.frame.size.height - 32 - 5 + 2, 25, 25)];
        [shareButton setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
        [self addSubview:shareButton];
        shareButton.hidden = YES;
        
        notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 32 - 5 - 32, self.frame.size.height - 32 - 5, 30, 30)];
        [notificationButton setImage:[UIImage imageNamed:@"Alert"] forState:UIControlStateNormal];
        [self addSubview:notificationButton];
        notificationButton.hidden = YES;
      
        settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 32, self.frame.size.height - 32 - 5, 30, 30)];
        [settingsButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
        [self addSubview:settingsButton];
//        [settingsButton setBackgroundColor:[UIColor redColor]];
        settingsButton.hidden = YES;
      
//        [mailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//          make.top.equalTo(filterTitleLabel.mas_bottom).with.offset(0);
//          make.left.equalTo(self.mas_centerX).with.offset(-(30/2));
//        }];
//      
//        // need to figure out how to do this with Masonry
//        constraint = [NSLayoutConstraint
//                      constraintWithItem:mailImageView
//                      attribute: NSLayoutAttributeHeight
//                      relatedBy:NSLayoutRelationEqual
//                      toItem:mailImageView
//                      attribute:NSLayoutAttributeHeight
//                      multiplier:0
//                      constant:23];
//      
//        [self addConstraint:constraint];
      
        messageCountLabel = [[UILabel alloc] init];
//        [newMessageCountLabel setFont:[UIFont systemFontOfSize:16]];
        messageCountLabel.textAlignment = NSTextAlignmentCenter;
        messageCountLabel.text = @"0";
//        newMessageCountLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        [messageCountLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:messageCountLabel];
      
        [messageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(mailImageView.mas_bottom).with.offset(0);
          make.centerX.equalTo(self.mas_centerX).with.offset(0);
        }];
      
        constraint = [NSLayoutConstraint
                      constraintWithItem:messageCountLabel
                      attribute: NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:messageCountLabel
                      attribute:NSLayoutAttributeHeight
                      multiplier:0
                      constant:25];
      
        [self addConstraint:constraint];
      
      
      /*
        dateOfLastMessageLabel = [[UILabel alloc] init];
        dateOfLastMessageLabel.textAlignment = NSTextAlignmentLeft;
        dateOfLastMessageLabel.text = @"1 hour ago";
        dateOfLastMessageLabel.font = [UIFont fontWithName:dateOfLastMessageLabel.font.fontName size:12.0];
        [self addSubview:dateOfLastMessageLabel];
      
        [dateOfLastMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.bottom.equalTo(self.mas_bottom).with.offset(0);
          make.left.equalTo(self.mas_left).with.offset(5);
        }];
      
        constraint = [NSLayoutConstraint
                      constraintWithItem:dateOfLastMessageLabel
                      attribute: NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:dateOfLastMessageLabel
                      attribute:NSLayoutAttributeHeight
                      multiplier:0
                      constant:25];
      
        [self addConstraint:constraint];

    
        typeLabel = [[UILabel alloc] init];
        typeLabel.textAlignment = NSTextAlignmentRight;
        typeLabel.text = @"All";
        typeLabel.font = [UIFont fontWithName:typeLabel.font.fontName size:12.0];
        [self addSubview:typeLabel];
      
        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.bottom.equalTo(self.mas_bottom).with.offset(0);
          make.right.equalTo(self.mas_right).with.offset(-5);
        }];
      
        constraint = [NSLayoutConstraint
                      constraintWithItem:typeLabel
                      attribute: NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:typeLabel
                      attribute:NSLayoutAttributeHeight
                      multiplier:0
                      constant:25];
      
        [self addConstraint:constraint];
      
      */

      
    }
    return self;
}

-(void) setBarColor:(UIColor *)barColor{
  _barColor = barColor;
  
  coloredBarView.backgroundColor = barColor;
}

-(void) setFilterTitle:(NSString *)filterTitle{
  _filterTitle = filterTitle;
  filterTitleLabel.text = filterTitle;
  if([filterTitleLabel.text isEqualToString:ADD_FUNNL]){
    filterTitleLabel.text = @"";
    messageCountLabel.hidden = YES;
    typeLabel.hidden = YES;
    dateOfLastMessageLabel.hidden = YES;
    mailImageView.contentMode = UIViewContentModeCenter;
    mailImageView.image = [UIImage imageNamed:@"add.png"];
    [mailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(filterTitleLabel.mas_bottom).with.offset(-20);
      make.left.equalTo(self.mas_centerX).with.offset(-(65/2));
    }];
    settingsButton.hidden = YES;
  }else{
        [mailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(filterTitleLabel.mas_bottom).with.offset(0);
          make.left.equalTo(self.mas_centerX).with.offset(-(45/2));
        }];
    settingsButton.hidden = NO;
    notificationButton.hidden = NO;
  }
  
  if([filterTitleLabel.text isEqualToString:@"All"]){
    settingsButton.hidden = YES;
    notificationButton.hidden = NO;
  }
  
}

-(void) setNewMessageCount:(NSInteger)newMessageCount{
  _newMessageCount = newMessageCount;
  messageCountLabel.text = [NSString stringWithFormat:@"%zd new", newMessageCount];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
