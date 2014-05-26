//
//  MainView.h
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "MainVCDelegate.h"

@interface MainView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>{
  NSArray *filterArray;
  FilterView *filterView;
}

@property (strong) UICollectionView *collectionView;
@property (weak) id<MainVCDelegate> mainVCdelegate;
-(void)reloadView;
@end
