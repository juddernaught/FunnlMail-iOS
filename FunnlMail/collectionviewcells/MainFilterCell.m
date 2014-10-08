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
//    NSLog(@"%f,%f,%f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    self = [super initWithFrame:CGRectMake(0, 0, 135, 135)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        self.clipsToBounds = YES;
//        self.layer.cornerRadius = frame.size.width/2.0;
        
        heightOfBackgroundView = 90;
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0 - heightOfBackgroundView/2.0, 1, heightOfBackgroundView, heightOfBackgroundView)];
        
        backgroundView.clipsToBounds = YES;
        backgroundView.layer.cornerRadius = heightOfBackgroundView/2.0;
        [self addSubview:backgroundView];
        
        filterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, heightOfBackgroundView, self.frame.size.width, self.frame.size.height - 1 - heightOfBackgroundView - 2)];
        [filterTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [filterTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        filterTitleLabel.numberOfLines = 2;
        filterTitleLabel.lineBreakMode = NSLineBreakByCharWrapping;
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
