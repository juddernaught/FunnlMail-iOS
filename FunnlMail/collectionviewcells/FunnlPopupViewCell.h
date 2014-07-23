//
//  FunnlPopupViewCell.h
//  FunnlMail
//
//  Created by macbook on 6/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunnlPopupViewCell : UICollectionViewCell{
    UIView *coloredBarView;
    UILabel *filterTitleLabel;
    //UIImageView *mailImageView;
    UILabel *dateOfLastMessageLabel;
    UILabel *typeLabel;

}

@property (strong,nonatomic) UIColor *barColor;
@property (copy,nonatomic) NSString *filterTitle;
@property (strong, nonatomic) UIImageView *mailImageView;

// Added by Chad
@property (assign,nonatomic) NSInteger newMessageCount;
@property (strong, nonatomic) UILabel *messageCountLabel;

@end