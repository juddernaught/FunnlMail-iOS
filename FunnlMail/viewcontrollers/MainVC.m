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
#import "RNBlurModalView.h"

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
    
    [self.view addSubview:mainView];
    
    // Set the navigation bar to white
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#F7F7F7"]];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    
    
    // This is the All bar
    NSLog(@"viewDidLoad mainVC");
    AppDelegate *tempAppDelegate = APPDELEGATE;
    tempAppDelegate.mainVCControllerInstance = self;
    currentFilterModel =  tempAppDelegate.currentSelectedFunnlModel;
    
    // Filter Title
    if (currentFilterModel && [currentFilterModel.funnelName isEqualToString:ALL_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
        self.navigationItem.title = currentFilterModel.funnelName;
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#F7F7F7"]];
    }
    else if (currentFilterModel &&  [currentFilterModel.funnelName isEqualToString:ALL_OTHER_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveOtherMessagesThanPrimary];
        self.navigationItem.title = currentFilterModel.funnelName;
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#F7F7F7"]];
        [[Mixpanel sharedInstance] track:@"Viewed 'All other' mail"];
    }
    else if(currentFilterModel)
    {
        self.navigationItem.title = currentFilterModel.funnelName;
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:currentFilterModel.funnelColor]];
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:currentFilterModel.funnelId top:2000];
    }
    else{
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#F7F7F7"]];
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
    }
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44+20, 320, 40)];
    _activityIndicator = tempAppDelegate.appActivityIndicator;
    [_activityIndicator setBackgroundColor:[UIColor clearColor]];
    [_activityIndicator startAnimating];
    [filterLabel addSubview:_activityIndicator];
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#F7F7F7"]);
    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle: ALL_FUNNL);
    filterLabel.textAlignment = NSTextAlignmentCenter;
  
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(menuButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    menuButton.frame = CGRectMake(0, 0, 20, 15);
    [menuButton setImage:[UIImage imageNamed:@"menuIcon.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 44)];
    //centeredButtons.backgroundColor = [UIColor orangeColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:centeredButtons];
    self.navigationItem.rightBarButtonItem = rightItem;
  
    //UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *composeEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [filterButton addTarget:self action:@selector(filterButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    filterButton.frame = CGRectMake(0, 4, 40, 40);
    [filterButton setImage:[UIImage imageNamed:@"funnlIcon.png"] forState:UIControlStateNormal];
    [filterButton setContentMode:UIViewContentModeCenter];
    [centeredButtons addSubview:filterButton];
    
    [composeEmailButton addTarget:self action:@selector(composeEmailButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    composeEmailButton.frame = CGRectMake(44, 0, 40, 40);
    [composeEmailButton setImage:[UIImage imageNamed:@"composeIcon.png"] forState:UIControlStateNormal];
    [composeEmailButton setContentMode:UIViewContentModeCenter];
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
    //[[EmailService instance] startLogin:emailsTableViewController];
}



#pragma mark -
#pragma mark Event-Handler
-(void)menuButtonSelected{
    NSLog(@"Menu button selected");
    [[Mixpanel sharedInstance] track:@"Tapped on Left menu bar button"];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [appDelegate.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

}



-(void) filterButtonSelected{
    [[Mixpanel sharedInstance] track:@"Tapped on Funnl button"];
    AppDelegate *tempAppDelegate = APPDELEGATE;
//    if (tempAppDelegate.funnelUpDated) {
//        tempAppDelegate.funnelUpDated = FALSE;
//        [mainView reloadView];
//    }
    [mainView reloadView];

    NSLog(@"Filter button selected");
    if(mainView.hidden == YES){
        mainView.hidden = NO;
        if (tempAppDelegate.didLoginIn) {
            tempAppDelegate.didLoginIn = 0;
            RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:@"Funnl Time!" message:@"Tap on any Funnl to view emails under that Funnl or press 'Manage' to view/change Funnl Settings"];
            [modal show];
        }
    }else{
        mainView.hidden = YES;
    }
    
}


-(void) composeEmailButtonSelected{
    NSLog(@"Compose Email selected");
    
    [[Mixpanel sharedInstance] track:@"Tapped on compose email"];
    
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
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.currentSelectedFunnlModel = filterModel;
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
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#F7F7F7"]];
    }
    else if ([filterModel.funnelName isEqualToString:ALL_OTHER_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveOtherMessagesThanPrimary];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#F7F7F7"]];

        [[Mixpanel sharedInstance] track:@"Viewed 'All other' mail"];
    }
    else
    {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:filterModel.funnelColor]];
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:filterModel.funnelId top:2000];
    }
    [self setFilterTitle:filterModel.funnelName];
    [emailsTableViewController.tableView reloadData];
    
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
