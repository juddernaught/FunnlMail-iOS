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

@implementation FunnlPopupViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithHexString:@"#E0E0EB"];
        
        coloredBarView = [[UIView alloc] init];
        coloredBarView.backgroundColor = self.barColor;
        [self addSubview:coloredBarView];
        
        mailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mail.png"]];
        mailImageView.frame = CGRectMake(0, 0, 29, 23);
        [self addSubview:mailImageView];
        
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
            make.center.equalTo(self);
        }];
        
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
        mailImageView.contentMode = UIViewContentModeCenter;
        mailImageView.image = [UIImage imageNamed:@"add.png"];
        [mailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(filterTitleLabel.mas_bottom).with.offset(0);
            make.left.equalTo(self.mas_centerX).with.offset(-(60/2));
        }];
        mailImageView.hidden = NO;
    }else{
        mailImageView.hidden = YES;
    }
}

@end
