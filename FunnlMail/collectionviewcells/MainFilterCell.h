//
//  MainFilterCell.h
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainFilterCell : UICollectionViewCell{
  UIView *coloredBarView;
  UILabel *filterTitleLabel;
  UILabel *newMessageCountLabel;
  UIImageView *mailImageView;
  UILabel *dateOfLastMessageLabel;
  UILabel *typeLabel;
}

@property (strong,nonatomic) UIColor *barColor;
@property (copy,nonatomic) NSString *filterTitle;
@property (assign,nonatomic) NSInteger newMessageCount;
@property (copy,nonatomic) NSDate *dateOfLastMessage;

@end