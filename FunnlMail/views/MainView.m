//
//  MainView.m
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MainView.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "MainFilterCell.h"
#import "FilterModel.h"
#import "EmailService.h"
#import "UIColor+HexString.h"
#import "CreateFunnlViewController.h"

static NSString *MAIN_FILTER_CELL = @"MainFilterCell";
static NSString *ADD_MAIN_FILTER_CELL = @"MainFilterCellAdd";

@implementation MainView

- (id)init
{
  self = [super init];
  if (self) {
    [self setup];
    [self setupViews];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)setup{
  filterArray = [[NSMutableArray alloc] init];
}

-(void)reloadView{
    filterArray = [EmailService getCurrentFilters];
    [self.collectionView reloadData];
}

- (void)setupViews
{
   
  filterArray = [EmailService getCurrentFilters];
	// Do any additional setup after loading the view.
  
  self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
  
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.scrollDirection = UICollectionViewScrollDirectionVertical;
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  //self.collectionView.backgroundColor = [UIColor greenColor];
  self.collectionView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
  self.collectionView.bounces = YES;
  self.collectionView.alwaysBounceVertical = YES;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  
  [self addSubview:self.collectionView];
  
  [self.collectionView registerClass:[MainFilterCell class] forCellWithReuseIdentifier:MAIN_FILTER_CELL];
  [self.collectionView registerClass:[MainFilterCell class] forCellWithReuseIdentifier:ADD_MAIN_FILTER_CELL];
  
  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.mas_top).with.offset(44);
    make.left.equalTo(self.mas_left).with.offset(80);
    make.right.equalTo(self.mas_right).with.offset(0);
    make.bottom.equalTo(self.mas_bottom).with.offset(-250);
  }];
  
  
  UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
  singleFingerTap.delegate = self;
  singleFingerTap.cancelsTouchesInView = NO;

  [self addGestureRecognizer:singleFingerTap];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//  CGPoint point = [touch locationInView:touch.view];
//  UIView *viewTouched = [touch.view hitTest:point withEvent:nil];
//  if ([viewTouched isKindOfClass:[UICollectionView class]]) {
//    // Do nothing;
//    return NO;
//  } else {
//    // respond to touch action
//    return YES;
//  }
//}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
  [self setHidden:YES];
}

#pragma mark - Collection view datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
  return [filterArray count]+1;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView{
  return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  MainFilterCell *cell;
  
  if(indexPath.row == filterArray.count){
    cell = (MainFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ADD_MAIN_FILTER_CELL forIndexPath:indexPath];
    cell.barColor = [UIColor colorWithHexString:@"#636466"];
    cell.filterTitle = ADD_FUNNL;
    cell.newMessageCount = 0;
    cell.dateOfLastMessage = 0;
  }
  else{
    cell = (MainFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MAIN_FILTER_CELL forIndexPath:indexPath];
    cell.barColor = [UIColor yellowColor];
    FilterModel *fm = (FilterModel *)filterArray[indexPath.row];
    cell.barColor = fm.barColor;
    cell.filterTitle = fm.filterTitle;
    cell.newMessageCount = fm.newMessageCount;
    cell.dateOfLastMessage = fm.dateOfLastMessage;
  
    cell.settingsButton.tag = indexPath.row;
    [cell.settingsButton addTarget:self action:@selector(settingsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    cell.notificationButton.tag = indexPath.row;
    //[cell.notificationButton addTarget:self action:@selector(notificationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

  }
  cell.contentView.backgroundColor = [UIColor whiteColor];
  return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
  return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.collectionView.frame.size.width-30)/2, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  //FilterViewVC *vc = [[FilterViewVC alloc] init];
  //vc.filterModel = (FilterModel *)filterArray[indexPath.row];
  
  //[self.navigationController pushViewController:vc animated:YES];
  if(indexPath.row == filterArray.count){
    [self createAddFunnlView];
  }else{
    [self.mainVCdelegate filterSelected:(FilterModel *)filterArray[indexPath.row]];
  }
}

-(void)createAddFunnlView{
  CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:nil subjects:nil filterModel:nil];
  creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
  [self.mainVCdelegate pushViewController:creatFunnlViewController];
  creatFunnlViewController = nil;
}

-(void)settingsButtonClicked:(id)sender{
  UIButton *b = (UIButton*)sender;
  FilterModel *fm = (FilterModel *)filterArray[b.tag];
  NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
  int count = 0;
  for (NSString *address in fm.sendersArray) {
    [sendersDictionary setObject:[address lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
    count ++;
  }
  
  NSMutableDictionary *subjectsDictionary = [[NSMutableDictionary alloc] init];
  count = 0;
  for (NSString *subject in fm.subjectsArray) {
    [subjectsDictionary setObject:[subject lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
    count ++;
  }
  
  CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:subjectsDictionary filterModel:fm];
  creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
  [self.mainVCdelegate pushViewController:creatFunnlViewController];
  creatFunnlViewController = nil;
}

-(void)notificationButtonClicked:(id)sender{
  UIButton *b = (UIButton*)sender;
}

@end
