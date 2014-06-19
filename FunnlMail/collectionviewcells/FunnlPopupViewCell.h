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
}

@property (strong,nonatomic) UIColor *barColor;
@property (copy,nonatomic) NSString *filterTitle;

@end