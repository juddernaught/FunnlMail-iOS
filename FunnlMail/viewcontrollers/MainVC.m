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
      
      //filterArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [mainView reloadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.view.backgroundColor = [UIColor whiteColor];
  
    /*mainView = [[MainView alloc] init];
    mainView.hidden = YES;
    mainView.mainVCdelegate = self;
    [self.view addSubview:mainView];
  
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
    }];*/
  
  
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 66, 28)];
    centeredButtons.backgroundColor = [UIColor orangeColor];
  
    self.navigationItem.titleView = centeredButtons;
  
    UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
  
    [mailButton addTarget:self action:@selector(mailButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    mailButton.frame = CGRectMake(0, 0, 33, 28);
    [mailButton setBackgroundImage:[UIImage imageNamed:@"Mail.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:mailButton];
  
    [filterButton addTarget:self action:@selector(filterButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    filterButton.frame = CGRectMake(33, 0, 33, 28);
    [filterButton setBackgroundImage:[UIImage imageNamed:@"Funnl.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:filterButton];
    
    if(emailsTableViewController==nil){
        emailsTableViewController = [[EmailsTableViewController alloc]init];
        emailsTableViewController.mainVCdelegate = self;
        
        [self addChildViewController:emailsTableViewController];
        [self.view insertSubview:emailsTableViewController.view atIndex:0];
        
        [emailsTableViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(0);
            make.left.equalTo(self.view.mas_left).with.offset(0);
            make.right.equalTo(self.view.mas_right).with.offset(0);
            make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
        }];
    }

}

-(void) mailButtonSelected{
    NSLog(@"Mail button selected");
  
    [self filterSelected:nil];
}

-(void) filterButtonSelected{
  NSLog(@"Filter button selected");
  
  //filterView.hidden = YES;
  //mainView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// FIXME: move somewhere else?
-(void) filterSelected:(FilterModel *)filterModel{
    if(filterModel!=nil){
        currentFilterModel = filterModel;
    }

    //mainView.hidden = YES;
    //filterView.hidden = NO;
    emailsTableViewController.filterModel = currentFilterModel;
    //[filterView startLogin];  // TODO: (MSR) I'm guessing we don't want to call this again, may need to refactor retrieving of messages
}

-(void) pushViewController:(UIViewController *)viewController{
  [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)prefersStatusBarHidden{
  return YES;
}

@end
