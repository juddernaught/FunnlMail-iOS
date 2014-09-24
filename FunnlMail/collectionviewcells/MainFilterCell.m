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
@synthesize notificationButton,settingsButton,mailImageView,messageCountLabel,shareButton,backgroundView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        self.clipsToBounds = YES;
//        self.layer.cornerRadius = frame.size.width/2.0;
        
        heightOfBackgroundView = 100;
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0 - heightOfBackgroundView/2.0, 1, heightOfBackgroundView, heightOfBackgroundView)];
        
        backgroundView.clipsToBounds = YES;
        backgroundView.layer.cornerRadius = heightOfBackgroundView/2.0;
        [self addSubview:backgroundView];
        
        filterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15 + heightOfBackgroundView, self.frame.size.width, self.frame.size.height - 1 - heightOfBackgroundView)];
        [filterTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [filterTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
//        filterTitleLabel.numberOfLines = 2;
//        filterTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [filterTitleLabel setBackgroundColor:[UIColor clearColor]];
        [filterTitleLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:filterTitleLabel];
        
        mailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(heightOfBackgroundView/2.0 - 25, heightOfBackgroundView/2.0 - 15.0/2.0, 20, 15)];
        UIImage *sampleImage = [UIImage imageNamed:@"Message.png"];
        sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [mailImageView setImage:sampleImage];
        mailImageView.tintColor = [UIColor whiteColor];
        [backgroundView addSubview:mailImageView];
        sampleImage = nil;
        
        messageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(heightOfBackgroundView/2.0 + 5, heightOfBackgroundView/2.0 - 15.0/2.0, 40, 15)];
        [messageCountLabel setTextColor:[UIColor whiteColor]];
        [messageCountLabel setTextAlignment:NSTextAlignmentLeft];
        [messageCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
        [backgroundView addSubview:messageCountLabel];
        
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(15, heightOfBackgroundView/2.0 - 20.0/2, 20, 20)];
        sampleImage = [UIImage imageNamed:@"Share.png"];
        sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [shareButton setImage:sampleImage forState:UIControlStateNormal];
        shareButton.imageView.tintColor = [UIColor whiteColor];
        [backgroundView addSubview:shareButton];
        shareButton.hidden = YES;
        sampleImage = nil;
        
//        notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(heightOfBackgroundView/2.0 - 25.0/2.0, heightOfBackgroundView/2.0 - 25.0/2, 25, 25)];
//        [notificationButton setImage:[UIImage imageNamed:@"Alert"] forState:UIControlStateNormal];
//        [backgroundView addSubview:notificationButton];
//        notificationButton.hidden = YES;
        
        settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(heightOfBackgroundView - 25.0 - 15, heightOfBackgroundView/2.0 - 25.0/2, 25, 25)];
        sampleImage = [UIImage imageNamed:@"Settings.png"];
        sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [settingsButton setImage:sampleImage forState:UIControlStateNormal];
        settingsButton.imageView.tintColor = [UIColor whiteColor];
        [backgroundView addSubview:settingsButton];
        settingsButton.hidden = YES;
        sampleImage = nil;
        
//        /*coloredBarView = [[UIView alloc] init];
//        coloredBarView.backgroundColor = self.barColor;
//        [self addSubview:coloredBarView];
//      
//        [coloredBarView mas_makeConstraints:^(MASConstraintMaker *make) {
//          make.top.equalTo(self.mas_top).with.offset(0);
//          make.left.equalTo(self.mas_left).with.offset(0);
//          make.width.equalTo(self.mas_width).with.offset(0);
//        }];*/
//      
//        // need to figure out how to do this with Masonry
//        /*NSLayoutConstraint *constraint = [NSLayoutConstraint
//                                          constraintWithItem:coloredBarView
//                                          attribute: NSLayoutAttributeHeight
//                                          relatedBy:NSLayoutRelationEqual
//                                          toItem:coloredBarView
//                                          attribute:NSLayoutAttributeHeight
//                                          multiplier:0
//                                          constant:10];
//      
//        [self addConstraint:constraint];*/
//      
//        self.barColor = [UIColor redColor];
//      
//        filterTitleLabel = [[UILabel alloc] init];
//        [filterTitleLabel setFont:[UIFont systemFontOfSize:18]];
//        filterTitleLabel.textAlignment = NSTextAlignmentCenter;
//        filterTitleLabel.text = ALL_FUNNL;
//        //filterTitleLabel.backgroundColor = [UIColor orangeColor];
//        [self addSubview:filterTitleLabel];
//      
//        [filterTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//          make.top.equalTo(coloredBarView.mas_bottom).with.offset(self.frame.size.height);
//          make.left.equalTo(coloredBarView.mas_left).with.offset((self.frame.size.width/2.0) - 50);
//          make.left.equalTo(coloredBarView.mas_left).with.offset((self.frame.size.width/2.0) - 50);
//          make.width.equalTo(coloredBarView.mas_width).with.offset(0);
//        }];
//      
//        NSLayoutConstraint *constraint = [NSLayoutConstraint
//                      constraintWithItem:filterTitleLabel
//                      attribute: NSLayoutAttributeHeight
//                      relatedBy:NSLayoutRelationEqual
//                      toItem:filterTitleLabel
//                      attribute:NSLayoutAttributeHeight
//                      multiplier:0
//                      constant:25];
//      
//        [self addConstraint:constraint];
//      
//         mailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Message.png"]];
////        mailImageView.frame = CGRectMake(0, 0, 30, 20);
//        [self addSubview:mailImageView];
//      
//        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(5 , self.frame.size.height/2.0 - 35.0/2.0 + 10, 35, 35)];
//        [shareButton setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
//        [self addSubview:shareButton];
//        shareButton.hidden = YES;
//        
//        notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 17, self.frame.size.height/2.0 - 35.0/2.0 + 10, 35, 35)];
//        [notificationButton setImage:[UIImage imageNamed:@"Alert"] forState:UIControlStateNormal];
//        [self addSubview:notificationButton];
//        notificationButton.hidden = YES;
//      
//        settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, self.frame.size.height/2.0 - 35.0/2.0 + 10, 35, 35)];
//        [settingsButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
//        [self addSubview:settingsButton];
////        [settingsButton setBackgroundColor:[UIColor redColor]];
//        settingsButton.hidden = YES;
//      
//
//      
//        messageCountLabel = [[UILabel alloc] init];
////        [newMessageCountLabel setFont:[UIFont systemFontOfSize:16]];
//        messageCountLabel.textAlignment = NSTextAlignmentCenter;
//        messageCountLabel.text = @"MainText";
////        newMessageCountLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
//        [messageCountLabel setFont:[UIFont systemFontOfSize:14]];
//        [self addSubview:messageCountLabel];
//      
//        [messageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//          make.top.equalTo(mailImageView.mas_bottom).with.offset(5);
//          make.centerX.equalTo(self.mas_centerX).with.offset(0);
//        }];
//      
//        constraint = [NSLayoutConstraint
//                      constraintWithItem:messageCountLabel
//                      attribute: NSLayoutAttributeHeight
//                      relatedBy:NSLayoutRelationEqual
//                      toItem:messageCountLabel
//                      attribute:NSLayoutAttributeHeight
//                      multiplier:0
//                      constant:25];
//      
//        [self addConstraint:constraint];
//      
//      
//      /*
//        dateOfLastMessageLabel = [[UILabel alloc] init];
//        dateOfLastMessageLabel.textAlignment = NSTextAlignmentLeft;
//        dateOfLastMessageLabel.text = @"1 hour ago";
//        dateOfLastMessageLabel.font = [UIFont fontWithName:dateOfLastMessageLabel.font.fontName size:12.0];
//        [self addSubview:dateOfLastMessageLabel];
//      
//        [dateOfLastMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//          make.bottom.equalTo(self.mas_bottom).with.offset(0);
//          make.left.equalTo(self.mas_left).with.offset(5);
//        }];
//      
//        constraint = [NSLayoutConstraint
//                      constraintWithItem:dateOfLastMessageLabel
//                      attribute: NSLayoutAttributeHeight
//                      relatedBy:NSLayoutRelationEqual
//                      toItem:dateOfLastMessageLabel
//                      attribute:NSLayoutAttributeHeight
//                      multiplier:0
//                      constant:25];
//      
//        [self addConstraint:constraint];
//
//    
//        typeLabel = [[UILabel alloc] init];
//        typeLabel.textAlignment = NSTextAlignmentRight;
//        typeLabel.text = @"All";
//        typeLabel.font = [UIFont fontWithName:typeLabel.font.fontName size:12.0];
//        [self addSubview:typeLabel];
//      
//        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//          make.bottom.equalTo(self.mas_bottom).with.offset(0);
//          make.right.equalTo(self.mas_right).with.offset(-5);
//        }];
//      
//        constraint = [NSLayoutConstraint
//                      constraintWithItem:typeLabel
//                      attribute: NSLayoutAttributeHeight
//                      relatedBy:NSLayoutRelationEqual
//                      toItem:typeLabel
//                      attribute:NSLayoutAttributeHeight
//                      multiplier:0
//                      constant:25];
//      
//        [self addConstraint:constraint];
//      
//      */

      
    }
    return self;
}

-(void) setBarColor:(UIColor *)barColor{
//  _barColor = barColor;
//    self.layer.borderColor = barColor.CGColor;
//    self.backgroundColor = barColor;
    backgroundView.backgroundColor = barColor;
//  coloredBarView.backgroundColor = barColor;
}

-(void) setFilterTitle:(NSString *)filterTitle{
  _filterTitle = filterTitle;
  filterTitleLabel.text = filterTitle;
  if([filterTitleLabel.text isEqualToString:ADD_FUNNL]){
    filterTitleLabel.text = @"ADD NEW";
      [backgroundView setBackgroundColor:[UIColor blackColor]];
    messageCountLabel.hidden = YES;
    typeLabel.hidden = YES;
    dateOfLastMessageLabel.hidden = YES;
    mailImageView.contentMode = UIViewContentModeCenter;
      mailImageView.frame = CGRectMake(0, 0, heightOfBackgroundView, heightOfBackgroundView);
    mailImageView.image = [UIImage imageNamed:@"addIcon-FunnlOverlay.png"];
    settingsButton.hidden = YES;
  }else{
    settingsButton.hidden = NO;
    notificationButton.hidden = NO;
  }
  
  if([[filterTitleLabel.text lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]] || [[filterTitleLabel.text lowercaseString] isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]){
    settingsButton.hidden = YES;
    notificationButton.hidden = NO;
      
  }
  
}

-(void) setNewMessageCount:(NSInteger)newMessageCount{
  _newMessageCount = newMessageCount;
  messageCountLabel.text = [NSString stringWithFormat:@"%zd", newMessageCount];
    
    // added by Chad
    if ([_filterTitle isEqualToString: ALL_FUNNL]) {
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: newMessageCount];
    }
    
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
