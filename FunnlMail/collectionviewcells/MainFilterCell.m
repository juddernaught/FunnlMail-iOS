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

@implementation MainFilterCell

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
        filterTitleLabel.textAlignment = NSTextAlignmentCenter;
        filterTitleLabel.text = @"Primary";
        //filterTitleLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:filterTitleLabel];
      
        [filterTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(coloredBarView.mas_bottom).with.offset(0);
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
      
        mailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mail.png"]];
        mailImageView.frame = CGRectMake(0, 0, 29, 23);
        [self addSubview:mailImageView];
      
        [mailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(filterTitleLabel.mas_bottom).with.offset(20);
          make.left.equalTo(self.mas_centerX).with.offset(-(30/2));
        }];
      
        // need to figure out how to do this with Masonry
        constraint = [NSLayoutConstraint
                      constraintWithItem:mailImageView
                      attribute: NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:mailImageView
                      attribute:NSLayoutAttributeHeight
                      multiplier:0
                      constant:23];
      
        [self addConstraint:constraint];
      
        newMessageCountLabel = [[UILabel alloc] init];
        newMessageCountLabel.textAlignment = NSTextAlignmentCenter;
        newMessageCountLabel.text = @"0";
        [self addSubview:newMessageCountLabel];
      
        [newMessageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(mailImageView.mas_bottom).with.offset(0);
          make.centerX.equalTo(self.mas_centerX).with.offset(0);
        }];
      
        constraint = [NSLayoutConstraint
                      constraintWithItem:newMessageCountLabel
                      attribute: NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:newMessageCountLabel
                      attribute:NSLayoutAttributeHeight
                      multiplier:0
                      constant:25];
      
        [self addConstraint:constraint];
      
      
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
}

-(void) setNewMessageCount:(NSInteger *)newMessageCount{
  _newMessageCount = newMessageCount;
  
  newMessageCountLabel.text = [NSString stringWithFormat:@"%zd", newMessageCount];
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
