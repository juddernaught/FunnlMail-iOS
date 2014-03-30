//
//  FilterViewVC.m
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FilterViewVC.h"
#import "FilterViewCell.h"
#import "View+MASAdditions.h"
#import "FilterModel.h"

static NSString *FILTER_VIEW_CELL = @"FilterViewCell";

@interface FilterViewVC ()

@end

@implementation FilterViewVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  filterNavigationView = [[UIView alloc]init];
  filterNavigationView.backgroundColor = [UIColor orangeColor];
  [self.view addSubview:filterNavigationView];
  
  [filterNavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_top).with.offset(44+20); // we should calculate this (self.topLayoutGuide.length?)
    make.left.equalTo(self.view.mas_left).with.offset(0);
    make.right.equalTo(self.view.mas_right).with.offset(0);
  }];
  
  // need to figure out how to do this with Masonry
  NSLayoutConstraint *constraint;
  constraint = [NSLayoutConstraint
                constraintWithItem:filterNavigationView
                attribute: NSLayoutAttributeHeight
                relatedBy:NSLayoutRelationEqual
                toItem:filterNavigationView
                attribute:NSLayoutAttributeHeight
                multiplier:0
                constant:22];
  
  [self.view addConstraint:constraint];
  
  filterLabel = [[UILabel alloc] init];
  filterLabel.textColor = [UIColor whiteColor];
  filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor yellowColor]);
  filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"");
  filterLabel.textAlignment = NSTextAlignmentCenter;
  [filterNavigationView addSubview:filterLabel];
  [filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(filterNavigationView.mas_top).with.offset(0);
    make.left.equalTo(filterNavigationView.mas_left).with.offset(0);
    make.right.equalTo(filterNavigationView.mas_right).with.offset(0);
    make.bottom.equalTo(filterNavigationView.mas_bottom).with.offset(0);
  }];
  
  self.tableView = [[UITableView alloc]init];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  [self.view addSubview:self.tableView];
  
  [self.tableView registerClass:[FilterViewCell class] forCellReuseIdentifier:FILTER_VIEW_CELL];
  
  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(filterLabel.mas_bottom).with.offset(0);
    make.left.equalTo(self.view.mas_left).with.offset(0);
    make.right.equalTo(self.view.mas_right).with.offset(0);
    make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
  }];
}

-(void) setFilterModel:(FilterModel *)filterModel{
  _filterModel = filterModel;
  
  if(filterLabel!=nil){
    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor yellowColor]);
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle : @"");
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FILTER_VIEW_CELL];
  
  return cell;
}

@end
