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
#import "MainView.h"
#import "EmailServersService.h"

#import <MessageUI/MessageUI.h>

static NSString *MAIN_FILTER_CELL = @"MainFilterCell";


@interface MainVC ()

@end

@implementation MainVC
@synthesize mainView,emailsTableViewController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.emailsTableViewController = [[EmailsTableViewController alloc]init];

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [mainView reloadView];
    AppDelegate *app = APPDELEGATE;
    NSLog(@"viewWillAppear mainVC");
    emailsTableViewController.emailFolder = INBOX;
    if([app.currentFunnelString.lowercaseString isEqualToString:[ALL_FUNNL lowercaseString]])
    {
         [self setTitle:ALL_FUNNL];
    }
    else
    {
         NSLog(@"do we get here tho: %@", self.parentViewController);
         NSLog(@"what is emailFolder in mainvc: %@",emailsTableViewController.emailFolder);
         //[self setTitle: app.currentFunnelString];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    mainView = [[MainView alloc] initWithFrame:CGRectMake(0, 20, WIDTH, HEIGHT+40)];
    mainView.hidden = YES;
    mainView.mainVCdelegate = self;
    mainView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.93];
//    mainView.blurRadius = 33;
    //take snapshot, then move off screen once complete
//    [mainView updateAsynchronously:YES completion:^{
//        mainView.frame = CGRectMake(0, 568, 320, 0);
//    }];
    
    [self.view addSubview:mainView];
    
    // Set the navigation bar to white
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
    
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
    tempAppDelegate.mainVCControllerInstance = self;
    if ([tempAppDelegate.currentFunnelString.lowercaseString isEqualToString:[ALL_FUNNL lowercaseString]]) {
        navigationBarTitleLabel.text = ALL_FUNNL;
        self.navigationItem.title = ALL_FUNNL;
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
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle: ALL_FUNNL);
    filterLabel.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:filterLabel];
//    self.navigationItem.title = filterLabel.text;
//    navigationBarTitleLabel.text = filterLabel.text;
    //*/



  
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(menuButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    menuButton.frame = CGRectMake(0, 0, 33, 28);
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menuIcon.png"] forState:UIControlStateNormal];
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
    [mailButton setBackgroundImage:[UIImage imageNamed:@"mail.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:mailButton];*/
  
    [filterButton addTarget:self action:@selector(filterButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    filterButton.frame = CGRectMake(15, 0, 32, 29);
    [filterButton setImage:[UIImage imageNamed:@"funnlIcon.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:filterButton];
    
    [composeEmailButton addTarget:self action:@selector(composeEmailButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    composeEmailButton.frame = CGRectMake(65, -5, 32, 32);
    [composeEmailButton setImage:[UIImage imageNamed:@"composeIcon.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:composeEmailButton];
    
    emailsTableViewController.emailFolder = INBOX;
    emailsTableViewController.mainVCdelegate = self;
    [self addChildViewController:emailsTableViewController];
    [self.view insertSubview:emailsTableViewController.view atIndex:0];
    
    [emailsTableViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
    }];
    [[EmailService instance] startLogin:emailsTableViewController];
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
//    if (tempAppDelegate.funnelUpDated) {
//        tempAppDelegate.funnelUpDated = FALSE;
//        [mainView reloadView];
//    }
    [mainView reloadView];

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
    mc.compose = @1;
//    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:mc];
//    [self.navigationController presentViewController:navBar animated:YES completion:NULL];
    [self.navigationController pushViewController:mc animated:YES];
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
    if ([title.lowercaseString isEqualToString:[ALL_FUNNL lowercaseString]]) {
        self.navigationItem.title = ALL_FUNNL;
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
    if ([filterModel.funnelName isEqualToString:ALL_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
    }
    else if ([filterModel.funnelName isEqualToString:ALL_OTHER_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveOtherMessagesThanPrimary];
    }
    else
    {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:filterModel.funnelId top:2000];
    }
    //self.navigationController.navigationBar.tintColor =  filterModel.barColor;
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
