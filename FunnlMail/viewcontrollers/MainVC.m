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
//#import "FilterModel.h"
#import "FunnelModel.h"
#import "EmailService.h"
#import "AppDelegate.h"
#import <Mixpanel/Mixpanel.h>
#import "UIColor+HexString.h"
#import "ComposeViewController.h"

#import <MessageUI/MessageUI.h>

static NSString *MAIN_FILTER_CELL = @"MainFilterCell";


@interface MainVC ()

@end

@implementation MainVC
@synthesize mainView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [mainView reloadView];
    AppDelegate *app = APPDELEGATE;
    NSLog(@"viewWillAppear mainVC");
    if([app.currentFunnelString.lowercaseString isEqualToString:@"all"]){
         [self setTitle:@"All Mail"];
        }
     else {
         NSLog(@"do we get here tho: %@", self.parentViewController);
         [self setTitle: app.currentFunnelString];
         }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    mainView = [[MainView alloc] init];
    mainView.hidden = YES;
    mainView.mainVCdelegate = self;
    [self.view addSubview:mainView];
    
    // Set the navigation bar to white
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
    }];
    
    // Filter Title
    self.navigationItem.title = currentFilterModel.funnelName;
//    navigationBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//    [navigationBarTitleLabel setFont:[UIFont systemFontOfSize:22.0]];
//    
//    [navigationBarTitleLabel setTextAlignment:NSTextAlignmentCenter];
//    [navigationBarTitleLabel setTextColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
//    self.navigationItem.titleView = navigationBarTitleLabel;
    
    // This is the All bar
    NSLog(@"viewDidLoad mainVC");
    AppDelegate *tempAppDelegate = APPDELEGATE;
    if ([tempAppDelegate.currentFunnelString.lowercaseString isEqualToString:@"all"]) {
        navigationBarTitleLabel.text = @"All Mail";
        self.navigationItem.title = @"All Mail";
    }
    else {
        self.navigationItem.title = tempAppDelegate.currentFunnelString.capitalizedString;
        navigationBarTitleLabel.text = tempAppDelegate.currentFunnelString.capitalizedString;
        self.navigationItem.title = @"Sent mail";
        navigationBarTitleLabel.text = @"Sent";
    }
    //>>>>>>> befb26a4459794a789ff1240527bd41eba700a00
    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44+20, 320, 40)];
    _activityIndicator = tempAppDelegate.appActivityIndicator;
    [_activityIndicator setBackgroundColor:[UIColor clearColor]];
    [_activityIndicator startAnimating];
    [filterLabel addSubview:_activityIndicator];
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#2EB82E"]);
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle: @"All");
    filterLabel.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:filterLabel];
//    self.navigationItem.title = filterLabel.text;
//    navigationBarTitleLabel.text = filterLabel.text;
    //*/


  
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(menuButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    menuButton.frame = CGRectMake(0, 0, 33, 28);
    [menuButton setBackgroundImage:[UIImage imageNamed:@"Menu1.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 99, 28)];
    //centeredButtons.backgroundColor = [UIColor orangeColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:centeredButtons];
    self.navigationItem.rightBarButtonItem = rightItem;
  
    //UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *composeEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
  
    /*[mailButton addTarget:self action:@selector(mailButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    mailButton.frame = CGRectMake(0, 0, 33, 28);
    [mailButton setBackgroundImage:[UIImage imageNamed:@"Mail.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:mailButton];*/
  
    [filterButton addTarget:self action:@selector(filterButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    filterButton.frame = CGRectMake(15, 0, 33, 33);
    [filterButton setBackgroundImage:[UIImage imageNamed:@"FunnlNew1.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:filterButton];
    
    [composeEmailButton addTarget:self action:@selector(composeEmailButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    composeEmailButton.frame = CGRectMake(66, -6, 33, 34);
    [composeEmailButton setBackgroundImage:[UIImage imageNamed:@"ComposeNew.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:composeEmailButton];
    
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

#pragma mark -
#pragma mark Event-Handler

-(void)menuButtonSelected{
    NSLog(@"Menu button selected");
    [[Mixpanel sharedInstance] track:@"Side Panel Requested"];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [appDelegate.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

}



-(void) filterButtonSelected{
    [[Mixpanel sharedInstance] track:@"Filter Button Selected"];
    AppDelegate *tempAppDelegate = APPDELEGATE;
    if (tempAppDelegate.funnelUpDated) {
        tempAppDelegate.funnelUpDated = FALSE;
        [mainView reloadView];
    }
    NSLog(@"Filter button selected");
    if(mainView.hidden == YES){
        mainView.hidden = NO;
    }else{
        mainView.hidden = YES;
    }
}


-(void) composeEmailButtonSelected{
    NSLog(@"Compose Email selected");
    [[Mixpanel sharedInstance] track:@"Compose Email Pressed"];
    mainView.hidden = YES;
    
    ComposeViewController *mc = [[ComposeViewController alloc] init];
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:mc];
    [self.navigationController presentViewController:navBar animated:YES completion:NULL];
}

#pragma mark -
#pragma mark Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark setFilterTitle
- (void)setFilterTitle:(NSString*)title
{
    if ([title.lowercaseString isEqualToString:@"all"]) {
        self.navigationItem.title = @"All Mail";
//        navigationBarTitleLabel.text = @"All mails";
    }
    else {
        self.navigationItem.title = title;
//        navigationBarTitleLabel.text = title;
    }
}

// FIXME: move somewhere else?
-(void) filterSelected:(FunnelModel *)filterModel{
    emailsTableViewController.isSearching = FALSE;
    [emailsTableViewController resetSearchBar];
    if(filterModel != nil){
        currentFilterModel = filterModel;
    }else{
      [EmailService getCurrentFilters];
    }
    mainView.hidden = YES;
    emailsTableViewController.filterModel = currentFilterModel;
    //fetching from database
    if ([filterModel.funnelId isEqualToString:@"0"]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
    }
    else
    {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:filterModel.funnelId top:2000];
    }
    [self setFilterTitle:filterModel.funnelName];
    [emailsTableViewController.tableView reloadData];
    
//    [emailsTableViewController.tableView setContentOffset:CGPointMake(0, -40)];
//    [filterView startLogin];  // TODO: (MSR) I'm guessing we don't want to call this again, may need to refactor retrieving of messages
}

-(void) pushViewController:(UIViewController *)viewController{
  [self.navigationController pushViewController:viewController animated:YES];
}

//-(UIStatusBarStyle)preferredStatusBarStyle{
//    AppDelegate *appDelegate = (AppDelegate*) [[ UIApplication sharedApplication ] delegate ];
//    if(appDelegate.drawerController.showsStatusBarBackgroundView){
//        return UIStatusBarStyleLightContent;
//    }
//    else {
//        return UIStatusBarStyleDefault;
//    }
//}

- (BOOL)prefersStatusBarHidden{
  return NO;
}

@end
