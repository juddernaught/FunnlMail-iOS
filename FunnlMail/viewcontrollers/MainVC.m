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
@synthesize segmentControl;
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
//         [self setTitle:ALL_FUNNL];
        NSLog(@"viewWillAppear ALL_FUNNL");
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
    segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Primary", @"Secondary", nil]];
    [segmentControl addTarget:self action:@selector(segmentControllerClicked:) forControlEvents:UIControlEventValueChanged];
    [segmentControl setSelectedSegmentIndex:0];
    [self.navigationItem setTitleView:segmentControl];
    self.view.backgroundColor = [UIColor whiteColor];
    mainView = [[MainView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    mainView.hidden = YES;
    mainView.mainVCdelegate = self;
    mainView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.93];
//    [self.view addSubview:mainView];
    
    AppDelegate *tempAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [tempAppDelegate.window addSubview:mainView];
    // Set the navigation bar to white
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xF7F7F7)];
    
    composeEmailButton.tintColor = UIColorFromRGB(0x007AFF);
    menuButton.tintColor = UIColorFromRGB(0x007AFF);
    filterButton.tintColor = UIColorFromRGB(0x007AFF);
    NSDictionary * navBarTitleTextAttributes =   @{ NSForegroundColorAttributeName : UIColorFromRGB(0x007AFF), NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
    [self.navigationController.navigationBar setTitleTextAttributes:navBarTitleTextAttributes];
    
    // This is the All bar
    NSLog(@"viewDidLoad mainVC");
//    AppDelegate *tempAppDelegate = APPDELEGATE;
    tempAppDelegate.mainVCControllerInstance = self;
    currentFilterModel =  tempAppDelegate.currentSelectedFunnlModel;
    
    // Filter Title
    if (currentFilterModel && [currentFilterModel.funnelName isEqualToString:ALL_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
        self.navigationItem.title = currentFilterModel.funnelName;
        //[self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xF7F7F7)];
    }
    else if (currentFilterModel &&  [currentFilterModel.funnelName isEqualToString:ALL_OTHER_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveOtherMessagesThanPrimary];
        self.navigationItem.title = ALL_OTHER_FUNNL_DISPLAY_NAME;
        //[self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xF7F7F7)];
#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Viewed 'All other' mail"];
#endif
    }
    else if(currentFilterModel)
    {
        self.navigationItem.title = currentFilterModel.funnelName;
//        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:currentFilterModel.funnelColor]];
        composeEmailButton.tintColor = [UIColor colorWithHexString:currentFilterModel.funnelColor];
        menuButton.tintColor = [UIColor colorWithHexString:currentFilterModel.funnelColor];
        filterButton.tintColor = [UIColor colorWithHexString:currentFilterModel.funnelColor];
        NSDictionary * navBarTitleTextAttributes =   @{ NSForegroundColorAttributeName : [UIColor colorWithHexString:currentFilterModel.funnelColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
        [self.navigationController.navigationBar setTitleTextAttributes:navBarTitleTextAttributes];

        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:currentFilterModel.funnelId top:2000];
    }
    else{
        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xF7F7F7)];
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
    }

//    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44+20, 320, 40)];
//    _activityIndicator = tempAppDelegate.appActivityIndicator;
//    [_activityIndicator setBackgroundColor:[UIColor clearColor]];
//    [_activityIndicator startAnimating];
//    [filterLabel addSubview:_activityIndicator];
//    filterLabel.textColor = [UIColor whiteColor];
//    filterLabel.backgroundColor = (self.filterModel!=nil ? self.filterModel.barColor : [UIColor colorWithHexString:@"#F7F7F7"]);
//    filterLabel.text = (self.filterModel!=nil ? self.filterModel.filterTitle: ALL_FUNNL);
//    filterLabel.textAlignment = NSTextAlignmentCenter;
  
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(menuButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    menuButton.frame = CGRectMake(0, 0, 20, 15);
    menuButton.contentEdgeInsets = (UIEdgeInsets){.left= 0};
    UIImage *menuIconImg = [UIImage imageNamed:@"menuIcon.png"];
    menuIconImg = [menuIconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [menuButton setImage:menuIconImg forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    centeredButtons.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:centeredButtons];
    self.navigationItem.rightBarButtonItem = rightItem;
  
    //UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    composeEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [filterButton addTarget:self action:@selector(filterButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    filterButton.frame = CGRectMake(0, 2, 40, 40);
    composeEmailButton.contentEdgeInsets = (UIEdgeInsets){.right=-4};
    UIImage *funnlIconImg = [UIImage imageNamed:@"funnlIcon.png"];
    funnlIconImg = [funnlIconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [filterButton setImage:funnlIconImg forState:UIControlStateNormal];
    [filterButton setContentMode:UIViewContentModeCenter];
    [centeredButtons addSubview:filterButton];
    
    [composeEmailButton addTarget:self action:@selector(composeEmailButtonSelected) forControlEvents:UIControlEventTouchUpInside];
//    composeEmailButton.contentEdgeInsets = (UIEdgeInsets){.right=0};
    composeEmailButton.frame = CGRectMake(35, -5, 50, 50);
    UIImage *composeIconImg = [UIImage imageNamed:@"composeIcon.png"];
    composeIconImg = [composeIconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [composeEmailButton setImage:composeIconImg forState:UIControlStateNormal];
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

- (void)settingTitleToButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@""]];
        [emailsTableViewController.helpButton setAttributedTitle:attString forState:UIControlStateNormal];
//        [emailsTableViewController.helpButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];


        if (emailsTableViewController.helpFlag) {
            [emailsTableViewController.helpButton setTitle:GUIDE_FOR_SWIPING_CELL forState:UIControlStateNormal];
            [emailsTableViewController.helpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else {
            [emailsTableViewController.helpButton setTitle:HELP_COMMENT forState:UIControlStateNormal];
            [emailsTableViewController.helpButton setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE] forState:UIControlStateNormal];
        }
        [emailsTableViewController.helpButton setNeedsDisplay];
        [emailsTableViewController.helpButton setNeedsLayout];
    });
}

#pragma mark -
#pragma mark Event-Handler

- (void)segmentControllerClicked:(UISegmentedControl*)sender {
    AppDelegate *tempAppDelegate = APPDELEGATE;
    NSArray *filterArray = [[FunnelService instance] allFunnels];
    tempAppDelegate.currentFunnelString = [[(FunnelModel *)filterArray[sender.selectedSegmentIndex] funnelName] lowercaseString];
    tempAppDelegate.currentFunnelDS = (FunnelModel *)filterArray[sender.selectedSegmentIndex];
    [self filterSelected:(FunnelModel *)filterArray[sender.selectedSegmentIndex]];
    filterArray = nil;
    tempAppDelegate = nil;
    if (sender.selectedSegmentIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[[MessageService instance] latestSecondaryTT] forKey:@"latest_tt_secondary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSelector:@selector(settingTitleToButton) withObject:nil afterDelay:0.01];
    }
    else if (sender.selectedSegmentIndex == 0) {
//        NSMutableString *tempArray1 = [[EmailService instance] retrieveSecondaryAfterStoredTT];
//        if (tempArray1.length > 2) {
//            NSString *displayString = [tempArray1 substringWithRange:NSMakeRange(0, tempArray1.length - 2)];
//            NSLog(@"%@",displayString);
//            [emailsTableViewController.helpButton setTitle:displayString forState:UIControlStateNormal];
//        }
    }
}

-(void)menuButtonSelected{
    NSLog(@"Menu button selected");
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Tapped on Left menu bar button"];
#endif
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [appDelegate.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

}

- (void)bacButtonSelected {
    [segmentControl setSelectedSegmentIndex:0];
    [self segmentControllerClicked:segmentControl];
}

-(void) filterButtonSelected{
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Tapped on Funnl button"];
#endif
    AppDelegate *tempAppDelegate = APPDELEGATE;
//    if (tempAppDelegate.funnelUpDated) {
//        tempAppDelegate.funnelUpDated = FALSE;
//        [mainView reloadView];
//    }
    [mainView reloadView];

    NSLog(@"Filter button selected");
    if(mainView.hidden == YES){
        mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
        mainView.center = self.view.center;
        mainView.hidden = NO;
        mainView.alpha = 0;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        mainView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        mainView.alpha = 1;
        [UIView commitAnimations];
        
        if (tempAppDelegate.didLoginIn) {
            tempAppDelegate.didLoginIn = 0;
//            RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:@"Funnl Time!" message:@"Tap on any Funnl to view emails under that Funnl or press 'Manage' to view/change Funnl Settings"];
//            [modal show];
        }
        [tempAppDelegate.window bringSubviewToFront:mainView];
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self hideMainView];
    }
    
}

- (void)hideMainView {
    mainView.alpha = 1;
    mainView.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void) composeEmailButtonSelected{
    NSLog(@"Compose Email selected");
    
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Tapped on compose email"];
#endif
    
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
        [self.navigationItem setTitleView:segmentControl];
//        navigationBarTitleLabel.text = @"All mails";
        segmentControl.hidden = NO;
    }
    else if ([title.lowercaseString isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
        self.navigationItem.title = ALL_OTHER_FUNNL_DISPLAY_NAME;
        //        navigationBarTitleLabel.text = @"All mails";
        [self.navigationItem setTitleView:segmentControl];
        segmentControl.hidden = NO;
    }
    else {
        self.navigationItem.title = title;
        UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        sampleLabel.text = title;
        [sampleLabel setTextAlignment:NSTextAlignmentCenter];
        [sampleLabel setTextColor:[UIColor colorWithHexString:currentFilterModel.funnelColor]];
        [self.navigationItem setTitleView:sampleLabel];
        sampleLabel = nil;
        [self.navigationItem setTitle:title];
        segmentControl.hidden = YES;
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
    
    composeEmailButton.tintColor = UIColorFromRGB(0x007AFF);
    menuButton.tintColor = UIColorFromRGB(0x007AFF);
    filterButton.tintColor = UIColorFromRGB(0x007AFF);

    NSDictionary * navBarTitleTextAttributes =   @{ NSForegroundColorAttributeName : UIColorFromRGB(0x007AFF), NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
    [self.navigationController.navigationBar setTitleTextAttributes:navBarTitleTextAttributes];

    //fetching from database
    if ([filterModel.funnelName isEqualToString:ALL_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton addTarget:self action:@selector(menuButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        menuButton.contentEdgeInsets = (UIEdgeInsets){.left= 0};
        menuButton.frame = CGRectMake(0, 0, 20, 15);
        UIImage *menuIconImg = [UIImage imageNamed:@"menuIcon.png"];
        menuIconImg = [menuIconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [menuButton setImage:menuIconImg forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    else if ([filterModel.funnelName isEqualToString:ALL_OTHER_FUNNL]) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] retrieveOtherMessagesThanPrimary];
#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Viewed 'All other' mail"];
#endif
//        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xF7F7F7)];
        
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.contentEdgeInsets = (UIEdgeInsets){.left= 0};
        [menuButton addTarget:self action:@selector(menuButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        menuButton.frame = CGRectMake(0, 0, 20, 15);
        UIImage *menuIconImg = [UIImage imageNamed:@"menuIcon.png"];
        menuIconImg = [menuIconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [menuButton setImage:menuIconImg forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    else
    {
        composeEmailButton.tintColor = [UIColor colorWithHexString:filterModel.funnelColor];
        menuButton.tintColor = [UIColor colorWithHexString:filterModel.funnelColor];
        filterButton.tintColor = [UIColor colorWithHexString:filterModel.funnelColor];
        NSDictionary * navBarTitleTextAttributes =   @{ NSForegroundColorAttributeName : [UIColor colorWithHexString:filterModel.funnelColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
        [self.navigationController.navigationBar setTitleTextAttributes:navBarTitleTextAttributes];
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:filterModel.funnelId top:2000];
      
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.tintColor = [UIColor colorWithHexString:filterModel.funnelColor];
        [menuButton addTarget:self action:@selector(bacButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        menuButton.frame = CGRectMake(0, 0, 100, 30);
        UIImage *menuIconImg = [UIImage imageNamed:@"primaryBackButton.png"];
        menuIconImg = [menuIconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [menuButton setImage:menuIconImg forState:UIControlStateNormal];
        menuButton.contentEdgeInsets = (UIEdgeInsets){.left=-15};
        [menuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = leftItem;
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
