//
//  MenuViewController.m
//  FunnlMail
//
//  Created by macbook on 6/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MenuViewController.h"
#import "UIColor+HexString.h"
#import "EmailService.h"
#import "MainVC.h"
#import "SDWebImageDownloader.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "EmailServersService.h"
#import "FunnlAlertsVC.h"
#import "ComposeViewController.h"
#import "FAQVC.h"
#import "SQLiteDatabase.h"
#import <Mixpanel/Mixpanel.h>
#import "TutorialViewController.h"
#import "FMFunnlStoreViewController.h"
#import "SPFirstViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize listArray,imageArray,listView,userImageView,emailLabel,userNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
//   return  UIStatusBarAnimationFade;
//}
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

-(void)viewWillAppear:(BOOL)animated{
    /*if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"]) {
        listArray =[[NSMutableArray alloc] initWithObjects:@"",@"Create Funnel", @"Funnel Store",@"Turn Off All Alerts", @"Send Feedback",@"Tutorial",@"Help (FAQs)",@"LogOut",nil];
    } else {
        listArray =[[NSMutableArray alloc] initWithObjects:@"",@"Create Funnel", @"Funnel Store", @"Turn On All Alerts", @"Send Feedback",@"Tutorial",@"Help (FAQs)",@"LogOut",nil];
    }*/
  listArray =[[NSMutableArray alloc] initWithObjects:@"",@"Create Funnel", @"Funnel Store", @"Alerts", @"Send Feedback",@"Tutorial",@"Help (FAQs)",@"LogOut",nil];
    imageArray = [[NSMutableArray alloc] initWithObjects:@"",@"funnlIcon",@"storeListIcon",@"notifyListIcon", @"sendFeedbackListIcon",@"tutorialListIcon",@"helpListIcon", @"logoutListIcon",nil];
    [listView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#2B2F31"];
    listView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 260, 568) style:UITableViewStyleGrouped] ;
    listView.delegate = self;
    listView.dataSource = self;
    listView.backgroundColor = [UIColor clearColor];
    listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:listView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    headerView.backgroundColor = CLEAR_COLOR;
    [listView setTableHeaderView:headerView];
    
    userImageView = [[UIImageView alloc ] initWithFrame:CGRectMake(10, 28, 44, 44)];
    userImageView.layer.cornerRadius = 22;
    userImageView.layer.masksToBounds = YES;
    NSString *imageUrl = [EmailService instance].userImageURL;
    if([imageUrl hasPrefix:@"http"]){
        [userImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"userimage-placeholder.png"] options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        }];
    }
    else
        userImageView.image = [UIImage imageNamed:@"userimage-placeholder.png"];
    [headerView addSubview:userImageView];
    
    userImageView.userInteractionEnabled = YES;
    headerView.userInteractionEnabled = YES;
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 28, 180, 20)];
    userNameLabel.textColor = WHITE_CLR;
    userNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    [headerView addSubview:userNameLabel];

    emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, 180, 40)];
    emailLabel.textColor = WHITE_CLR;
    emailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [headerView addSubview:emailLabel];

    UILabel *sepLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 320, 1)];
    sepLineLabel.backgroundColor = UIColorFromRGB(0x43484A);
    [headerView addSubview:sepLineLabel];

        //original
//    listArray =[[NSMutableArray alloc] initWithObjects:@"Email Account", @"Sent Mail", @"Archive",@"Drafts", @"Trash",@"Send Feedback",@"Help",@"LogOut",nil];
//    imageArray = [[NSMutableArray alloc] initWithObjects:@"emailListIcon",@"settingListIcon",@"alertListIcon",@"shareListIcon",@"sentListIcon", @"archiveListIcon",@"archiveListIcon", @"trashListIcon",@"emailListIcon",@"helpListIcon", @"helpListLogOutIcon",nil];
    
   

}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return [listArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    if(indexPath.row == 0)
        return 60;
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)_cell forRowAtIndexPath:(NSIndexPath *)indexPath;{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MenuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
	{
		cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    cell.menuLabel.text = [listArray objectAtIndex:indexPath.row] ;
    cell.menuLabel.backgroundColor = CLEAR_COLOR;
    cell.menuLabel.textColor = WHITE_CLR;
    cell.menuLabel.highlightedTextColor = UIColorFromRGB(0x1B8EEE);
    
    cell.contentView.backgroundColor = CLEAR_COLOR;
    cell.backgroundColor = CLEAR_COLOR;
    cell.contentView.backgroundColor = CLEAR_COLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setAccessoryType:UITableViewCellAccessoryNone];

    if ([[imageArray objectAtIndex:indexPath.row] isEqualToString:@"funnlIcon"]) {
        UIImage *funnlIconImg = [UIImage imageNamed:@"funnlIcon.png"];
        funnlIconImg = [funnlIconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.menuImage.image = funnlIconImg;
        cell.menuImage.tintColor = [UIColor whiteColor];
    }
    else {
        cell.menuImage.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
    AppDelegate *appDelegate = APPDELEGATE;
    MenuCell *cell = (MenuCell*)[tableView cellForRowAtIndexPath:indexPath];
    
//    if(indexPath.row == 0){
//        [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
//        AppDelegate *tempAppDelegate = APPDELEGATE;
//        NSMutableArray *filterArray = (NSMutableArray*)[[FunnelService instance] allFunnels];
//        FunnelModel *primaryFunnl = nil;
//        for (FunnelModel *f in filterArray) {
//            if([[f.funnelName lowercaseString] isEqualToString:[ALL_FUNNL lowercaseString]]){
//                primaryFunnl = f;
//                break;
//            }
//        }
//
//        if(primaryFunnl){
//            tempAppDelegate.currentFunnelString = [primaryFunnl.funnelName lowercaseString];
//            tempAppDelegate.currentFunnelDS = primaryFunnl;
//            [tempAppDelegate.mainVCdelegate filterSelected:primaryFunnl];
//            [tempAppDelegate.drawerController closeDrawerAnimated:YES completion:nil];
//        }
//
//        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
//        return;
//    }
    
    if([cell.menuLabel.text isEqualToString:@"Help (FAQs)"]){
        FAQVC *faq = [[FAQVC alloc]init];
        [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:faq animated:NO];
    }
    else if ([cell.menuLabel.text isEqualToString:@"Alerts"]) {
      FMNotificationsViewController *notificationsViewController = [[FMNotificationsViewController alloc] init];
      [appDelegate.drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:notificationsViewController animated:YES];
      }];
    }
    /*else if([cell.menuLabel.text isEqualToString:@"Turn On All Alerts"]){
        cell.menuLabel.text = @"Turn Off All Alerts";
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
            NSString *webhook_id = [responseDict objectForKey:@"webhook_id"];
            [[NSUserDefaults standardUserDefaults] setObject:webhook_id forKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
        }];
    }
    else if([cell.menuLabel.text isEqualToString:@"Turn Off All Alerts"]){
        cell.menuLabel.text = @"Turn On All Alerts";
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).contextIOAPIClient deleteWebhookWithID:[[NSUserDefaults standardUserDefaults] stringForKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"] success:^(NSDictionary *responseDict) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
        }];
    }*/
    
    else if ([cell.menuLabel.text isEqualToString:@"Funnl Alerts"]){
        FunnlAlertsVC *alerts = [[FunnlAlertsVC alloc]init];
        [alerts SetUp];
        [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:alerts animated:NO];
    }
    else if([cell.menuLabel.text isEqualToString:@"Tutorial"]){
        SPFirstViewController *viewController = [[SPFirstViewController alloc] init];
        [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:viewController animated:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"outter_tutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        TutorialViewController *tutorialVC = [[TutorialViewController alloc]init];
//        [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:tutorialVC animated:NO];
        
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Sent Mail"]) {
        NSLog(@"sent mail requested");
        [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Viewed sent mail"];
#endif
         //The following line is required to get to the emailTableVC in mainVC
         // [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject;
    
        appDelegate.currentFunnelString = SENT;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Sent Mails";
        [[EmailService instance] getDatabaseMessages:SENT withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
       
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:SENT withFetchRange:MCORangeEmpty];
        //[MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];

    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Archive"]){
        NSLog(@"archive mail requested");
        [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];

#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Viewed archive mail"];
#endif
        
        appDelegate.currentFunnelString = ARCHIVE;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Archive";
        [[EmailService instance] getDatabaseMessages:ARCHIVE withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:ARCHIVE withFetchRange:MCORangeEmpty];
    
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Drafts"]){
        [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];

#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Viewed drafts"];
#endif
        
        appDelegate.currentFunnelString = DRAFTS;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Drafts";
        [[EmailService instance] getDatabaseMessages:DRAFTS withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:DRAFTS withFetchRange:MCORangeEmpty];
    
        //[MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    }
    else if ([cell.menuLabel.text isEqualToString:@"Funnel Store"]){
        FMFunnlStoreViewController *controller = [[FMFunnlStoreViewController alloc]init];
        controller.view.backgroundColor = [UIColor clearColor];
        appDelegate.window.backgroundColor = [UIColor whiteColor];
        [appDelegate.drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:controller animated:NO];
        }];
    }
    else if ([cell.menuLabel.text isEqualToString:@"Trash"]){
        NSLog(@"trash mail requested");
        [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];

#ifdef TRACK_MIXPANEL
        //[[Mixpanel sharedInstance] track:@"Viewed trash"];
#endif
        
        appDelegate.currentFunnelString = TRASH;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Trash";
        [[EmailService instance] getDatabaseMessages:TRASH withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:TRASH withFetchRange:MCORangeEmpty];
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"LogOut"]){
        [NSObject cancelPreviousPerformRequestsWithTarget:appDelegate];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"show_vip"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"latest_tt_secondary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        [[EmailServersService instance] deleteEmailServer:[EmailService instance].userEmailID];
        [NSObject cancelPreviousPerformRequestsWithTarget:[EmailService instance]];
        [[MessageService instance] clearAllTables];
        [[EmailService instance].imapCheckOp cancel];
        [[EmailService instance].imapMessagesFetchOp cancel];
        [[EmailService instance].imapSession cancelAllOperations];

        [appDelegate.contextIOAPIClient clearCredentials];
        appDelegate.currentFunnelDS = nil;
        appDelegate.currentFunnelString = nil;
        appDelegate.currentSelectedFunnlModel = nil;
        [SQLiteDatabase sharedInstance];
        [[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray new] forKey: ALL_FUNNL];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PRIMARY_PAGE_TOKEN"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_NEW_INSTALL"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"MODSEQ"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"EMAIL_LOGGED_IN"];
        [[EmailService instance] clearData];
        [EmailService instance].userEmailID = @"";

        
        FunnelModel *defaultFilter = [[FunnelModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#F7F7F7"] filterTitle:ALL_FUNNL newMessageCount:0 dateOfLastMessage:[NSDate new]];
        defaultFilter.funnelName = ALL_FUNNL;
        defaultFilter.funnelId = @"0";
        defaultFilter.emailAddresses = @"";
        defaultFilter.webhookIds = @"";
        defaultFilter.phrases = @"";
        [[FunnelService instance] insertFunnel:defaultFilter];
        defaultFilter = nil;
        
        FunnelModel *otherFilter = [[FunnelModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#F7F7F7"] filterTitle:ALL_OTHER_FUNNL newMessageCount:0 dateOfLastMessage:[NSDate new]];
        otherFilter.funnelName = ALL_OTHER_FUNNL;
        otherFilter.funnelId = @"1";
        otherFilter.emailAddresses = @"";
        otherFilter.webhookIds = @"";
        otherFilter.phrases = @"";
        [[FunnelService instance] insertFunnel:otherFilter];
        otherFilter = nil;

        
        LoginViewController *loginViewController = [[LoginViewController alloc]init];
        loginViewController.view.backgroundColor = [UIColor clearColor];
        appDelegate.window.backgroundColor = [UIColor whiteColor];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginViewController];
        [appDelegate.window setRootViewController:nav];
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Send Feedback"]){
        NSLog(@"Send Feedback requested");
        ComposeViewController *mc = [[ComposeViewController alloc] init];
        mc.sendFeedback = @1;
        [appDelegate.drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:mc animated:NO];
        }];
    }

    else if ([cell.menuLabel.text isEqualToString:@"Create Funnel"]) {
        appDelegate =APPDELEGATE;
        appDelegate.loginViewController.mainViewController.emailsTableViewController.helpFlag = FALSE;
        [appDelegate.loginViewController.mainViewController.emailsTableViewController helpButtonPressed:appDelegate.loginViewController.mainViewController.emailsTableViewController.helpButton];
    }
    [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
