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
//#import "FilterModel.h"
#import "FunnelModel.h"
//newly added by iauro001 on 10th June 2014
#import "FunnelService.h"
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
      editOn = FALSE;
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
    NSLog(@"Did this Happen in MainView");
    filterArray = [[FunnelService instance] allFunnels];
    [self.collectionView reloadData];
}

- (void)setupViews
{
	// Do any additional setup after loading the view.
    //changes made by iauro001 on 11 June 2014
    //inserting default @"All" filter
    FunnelModel *defaultFilter = [[FunnelModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#2EB82E"] filterTitle:@"All" newMessageCount:16 dateOfLastMessage:[NSDate new]];
    defaultFilter.funnelName = @"All";
    defaultFilter.funnelId = @"0";
    defaultFilter.emailAddresses = @"";
    defaultFilter.phrases = @"";
    [[FunnelService instance] insertFunnel:defaultFilter];
    defaultFilter = nil;
//  filterArray = [EmailService getCurrentFilters];
//  NSArray *filterArray1 = [[FunnelService instance] allFunnels];
//    if (filterArray1.count >= filterArray.count) {
//        filterArray = [[FunnelService instance] allFunnels];
//        [EmailService instance].filterArray = (NSMutableArray*)filterArray1;
//    }
    filterArray = [[FunnelService instance] allFunnels];
  self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    UIButton *outterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [outterButton addTarget:self action:@selector(outterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:outterButton];
    
    UIView *headerView =[[UIView alloc] init];
    [self addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(120-40);
        make.left.equalTo(self.mas_left).with.offset(80);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.bottom.equalTo(self.mas_bottom).with.offset(-330);
    }];
    UILabel *funnelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
    funnelLabel.text = @"Funnls";
    [funnelLabel setTextAlignment:NSTextAlignmentLeft];
    [funnelLabel setFont:[UIFont systemFontOfSize:20]];
    [headerView addSubview:funnelLabel];
    [headerView setBackgroundColor:[UIColor colorWithHexString:@"#E2E2E2"]];
    
    editButton = [[UIButton alloc] initWithFrame:CGRectMake(320 - 80 - 85 - 10, 10, 85, 30)];
    [editButton setImage:[UIImage imageNamed:@"manage_Button"] forState:UIControlStateNormal];
    [editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [editButton setTitle:@"edit" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editButton];
    
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
        make.top.equalTo(self.mas_top).with.offset(120);
        make.left.equalTo(self.mas_left).with.offset(80);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.bottom.equalTo(self.mas_bottom).with.offset(-100);
    }];
  
  
//  UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//  singleFingerTap.delegate = self;
//  singleFingerTap.cancelsTouchesInView = NO;
//
//  [self addGestureRecognizer:singleFingerTap];
}

- (void)outterButtonClicked {
  [self setHidden:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
  [self setHidden:YES];
}

- (void)editButtonPressed:(UIButton*)sender {
    if (editOn) {
        editOn = FALSE;
        [editButton setImage:[UIImage imageNamed:@"manage_Button"] forState:UIControlStateNormal];
    }
    else {
        editOn = TRUE;
        [editButton setImage:[UIImage imageNamed:@"Done_Button"] forState:UIControlStateNormal];
    }
    [self.collectionView reloadData];
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
    FunnelModel *fm = (FunnelModel *)filterArray[indexPath.row];
    cell.barColor = [UIColor colorWithHexString:fm.funnelColor];
    cell.filterTitle = fm.filterTitle;
    cell.newMessageCount = fm.newMessageCount;
    cell.dateOfLastMessage = fm.dateOfLastMessage;
    cell.settingsButton.tag = indexPath.row;
    [cell.settingsButton addTarget:self action:@selector(settingsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.notificationButton.tag = indexPath.row;
    //[cell.notificationButton addTarget:self action:@selector(notificationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
      if (editOn && ![fm.funnelName.lowercaseString isEqualToString:@"all"]) {
          [cell.notificationButton setHidden:NO];
          [cell.settingsButton setHidden:NO];
          [cell.shareButton setHidden:NO];
          [cell.mailImageView setHidden:YES];
          [cell.messageCountLabel setHidden:YES];
      }
      else {
          [cell.notificationButton setHidden:YES];
          [cell.settingsButton setHidden:YES];
          [cell.shareButton setHidden:YES];
          [cell.mailImageView setHidden:NO];
          [cell.messageCountLabel setHidden:NO];
      }
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
  if(indexPath.row == filterArray.count){
    [self createAddFunnlView];
  }else{
    AppDelegate *tempAppDelegate = APPDELEGATE;
    tempAppDelegate.currentFunnelString = [[(FunnelModel *)filterArray[indexPath.row] funnelName] lowercaseString];
      tempAppDelegate.currentFunnelDS = (FunnelModel *)filterArray[indexPath.row];
    [self.mainVCdelegate filterSelected:(FunnelModel *)filterArray[indexPath.row]];
  }
}

-(void)createAddFunnlView{
  CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:nil subjects:nil filterModel:nil];
  creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
  [self.mainVCdelegate pushViewController:creatFunnlViewController];
  creatFunnlViewController = nil;
}

-(void)settingsButtonClicked:(id)sender{
    NSLog(@"Settings Button Clicked");
  UIButton *b = (UIButton*)sender;
  FunnelModel *fm = (FunnelModel *)filterArray[b.tag];
  NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
  int count = 0;
  for (NSString *address in fm.sendersArray) {
    [sendersDictionary setObject:[address lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
    count ++;
  }
  
  NSMutableDictionary *subjectsDictionary = [[NSMutableDictionary alloc] init];
  count = 0;
  for (NSString *subject in fm.subjectsArray) {
      if (![subject isEqualToString:@""])
      {
          [subjectsDictionary setObject:[subject lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:2]];
          count ++;
      }
  }
  
  CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:subjectsDictionary filterModel:fm];
  creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
  [self.mainVCdelegate pushViewController:creatFunnlViewController];
  creatFunnlViewController = nil;
}

-(void)notificationButtonClicked:(id)sender{
//  UIButton *b = (UIButton*)sender;
}

@end
