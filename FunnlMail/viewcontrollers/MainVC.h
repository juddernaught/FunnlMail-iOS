//
//  MainVC.h
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>{
  NSMutableArray *filterArray;
}

@property (strong) UICollectionView *collectionView;

@end
