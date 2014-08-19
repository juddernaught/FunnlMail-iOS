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

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize listArray,imageArray,listView;
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
    self.view.backgroundColor = [UIColor colorWithHexString:@"#4C4C4C"];
    listView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 260, 568) style:UITableViewStyleGrouped] ;
    listView.delegate = self;
    listView.dataSource = self;
    listView.backgroundColor = [UIColor clearColor];
    listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:listView];
    
    UIView *headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    headerLine.backgroundColor = WHITE_CLR;
    [self.view addSubview:headerLine];
    
//    [listView setBackgroundView:[[UIView alloc] init]];
    listArray =[[NSMutableArray alloc] initWithObjects:@"Email Account",@"Edit Funnl Settings",@"Funnl Alerts", @"Share Funnls", @"Sent Mail", @"Archive",@"Drafts", @"Trash",@"Send Feedback",@"Help",nil];
    imageArray = [[NSMutableArray alloc] initWithObjects:@"emailListIcon",@"settingListIcon",@"alertListIcon",@"shareListIcon",@"sentListIcon", @"archiveListIcon",@"archiveListIcon", @"trashListIcon",@"emailListIcon",@"helpListIcon", nil];
    
    
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return [listArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
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
    
    if(indexPath.row == 0){
        NSString *imageUrl = [imageArray objectAtIndex:indexPath.row];
        if([imageUrl hasPrefix:@"http"]){
            [cell.menuImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"userimage-placeholder.png"] options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
            }];
        }
        else
            cell.menuImage.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];

    }
    else
        cell.menuImage.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
    
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
//    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
    AppDelegate *appDelegate = APPDELEGATE;
    MenuCell *cell = (MenuCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.menuLabel.text isEqualToString:@"Help"]){
        FAQVC *faq = [[FAQVC alloc]init];
        [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:faq animated:NO];
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Funnl Alerts"]){
        FunnlAlertsVC *alerts = [[FunnlAlertsVC alloc]init];
        [alerts SetUp];
        [[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationController pushViewController:alerts animated:NO];
        
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Sent Mail"]) {
        NSLog(@"sent mail requested");
         //The following line is required to get to the emailTableVC in mainVC
         // [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject;
    
        appDelegate.currentFunnelString = SENT;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Sent Mails";
        [[EmailService instance] getDatabaseMessages:SENT withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
       
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:SENT withFetchRange:MCORangeEmpty];
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Archive"]){
        NSLog(@"archive mail requested");
        appDelegate.currentFunnelString = ARCHIVE;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Archive";
        [[EmailService instance] getDatabaseMessages:ARCHIVE withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:ARCHIVE withFetchRange:MCORangeEmpty];
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Drafts"]){
        appDelegate.currentFunnelString = DRAFTS;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Drafts";
        [[EmailService instance] getDatabaseMessages:DRAFTS withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:DRAFTS withFetchRange:MCORangeEmpty];
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Trash"]){
        NSLog(@"trash mail requested");
        appDelegate.currentFunnelString = TRASH;
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Trash";
        [[EmailService instance] getDatabaseMessages:TRASH withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject];
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:TRASH withFetchRange:MCORangeEmpty];
    }
    
    else if ([cell.menuLabel.text isEqualToString:@"Logout"]){
        [[MessageService instance] deleteMessageWithGmailMessageID:[EmailService instance].userEmailID];
        [[EmailServersService instance] deleteEmailServer:[EmailService instance].userEmailID];
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
