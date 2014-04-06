//
//  MainVC.m
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MainVC.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "MainFilterCell.h"
#import "FilterModel.h"
#import "FilterViewVC.h"
#import "EmailService.h"



static NSString *MAIN_FILTER_CELL = @"MainFilterCell";


@interface MainVC ()

@end

@implementation MainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization
      
      filterArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  filterArray = [EmailService currentFilters];
    
	// Do any additional setup after loading the view.
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.scrollDirection = UICollectionViewScrollDirectionVertical;
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  //self.collectionView.backgroundColor = [UIColor greenColor];
  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.collectionView.bounces = YES;
  self.collectionView.alwaysBounceVertical = YES;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;

  [self.view addSubview:self.collectionView];
  
  [self.collectionView registerClass:[MainFilterCell class] forCellWithReuseIdentifier:MAIN_FILTER_CELL];
  
  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_top).with.offset(0);
    make.left.equalTo(self.view.mas_left).with.offset(0);
    make.right.equalTo(self.view.mas_right).with.offset(0);
    make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
  }];
    //[EmailService login];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
  return [filterArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView{
  return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  MainFilterCell *cell = (MainFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MAIN_FILTER_CELL forIndexPath:indexPath];
  
  cell.barColor = [UIColor yellowColor];
  
  FilterModel *fm = (FilterModel *)filterArray[indexPath.row];
  
  cell.barColor = fm.barColor;
  cell.filterTitle = fm.filterTitle;
  cell.newMessageCount = fm.newMessageCount;
  cell.dateOfLastMessage = fm.dateOfLastMessage;
  
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  if(indexPath.row==0){
    return CGSizeMake((self.collectionView.frame.size.width-10), 160);
  }
  else{
    return CGSizeMake((self.collectionView.frame.size.width-10)/2, 160);
  }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  FilterViewVC *vc = [[FilterViewVC alloc] init];
  vc.filterModel = (FilterModel *)filterArray[indexPath.row];
  
  [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)prefersStatusBarHidden{
  return YES;
}

@end
