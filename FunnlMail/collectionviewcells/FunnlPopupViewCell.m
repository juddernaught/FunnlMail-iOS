//
//  FunnlPopupViewCell.m
//  FunnlMail
//
//  Created by macbook on 6/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnlPopupViewCell.h"
#import "MainFilterCell.h"
#import "View+MASAdditions.h"
#import "UIColor+HexString.h"
#import "MASConstraintMaker.h"
#import <Mixpanel/Mixpanel.h>

@implementation FunnlPopupViewCell
@synthesize mailImageView,messageCountLabel;
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
        filterTitleLabel.numberOfLines = 0;
        filterTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        filterTitleLabel.textAlignment = NSTextAlignmentCenter;
        filterTitleLabel.text = ALL_FUNNL;
        //filterTitleLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:filterTitleLabel];
        
        [filterTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(coloredBarView.mas_bottom).with.offset(5);
            make.left.equalTo(coloredBarView.mas_left).with.offset(0);
            make.width.equalTo(coloredBarView.mas_width).with.offset(0);
        }];
        
        mailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Message.png"]];
//        mailImageView.frame = CGRectMake(0, 0, 29, 23);
        [self addSubview:mailImageView];
        
                // Added by Chad
        messageCountLabel = [[UILabel alloc] init];
        //        [newMessageCountLabel setFont:[UIFont systemFontOfSize:16]];
        messageCountLabel.textAlignment = NSTextAlignmentCenter;
        messageCountLabel.text = @"1212";
        //   newMessageCountLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        [messageCountLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:messageCountLabel];
        
        [messageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(mailImageView.mas_bottom).with.offset(5);
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
        
#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Pressed '+' button inside Funnl overlay"];
#endif
        
        filterTitleLabel.text = @"";
        messageCountLabel.hidden = YES;
        dateOfLastMessageLabel.hidden = YES;
        
        mailImageView.contentMode = UIViewContentModeCenter;
        mailImageView.image = [UIImage imageNamed:@"addIcon.png"];
        [mailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(filterTitleLabel.mas_bottom).with.offset(15);
            make.left.equalTo(self.mas_centerX).with.offset(-(65/2));
        }];
        mailImageView.hidden = NO;
        messageCountLabel.hidden = YES;
    }else{
        mailImageView.image = [UIImage imageNamed:@"Message.png"];
        [mailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(filterTitleLabel.mas_bottom).with.offset(5);
            make.left.equalTo(self.mas_centerX).with.offset(-(50/2));
        }];

        
    }
}

// Added by Chad
-(void) setNewMessageCount:(NSInteger)newMessageCount{
    _newMessageCount = newMessageCount;
    messageCountLabel.text = [NSString stringWithFormat:@"%zd new", newMessageCount];
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:99]; //added by Chad
}


@end
