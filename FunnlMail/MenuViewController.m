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
#import "MainView.h"




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
    listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:listView];
    
    UIView *headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    headerLine.backgroundColor = WHITE_CLR;
    [self.view addSubview:headerLine];
    
//    [listView setBackgroundView:[[UIView alloc] init]];
    listArray =[[NSMutableArray alloc] initWithObjects:@"Email Account",@"Inbox",@"Funnl Alerts", @"Sent Mail", @"Archive",@"Drafts", @"Trash", @"Help/FAQ",@"Send Feedback",nil];
    imageArray = [[NSMutableArray alloc] initWithObjects:@"emailListIcon",@"settingListIcon",@"alertListIcon",@"shareListIcon",@"sentListIcon", @"archiveListIcon",@"Edit_Button", @"trashListIcon",@"helpListIcon", nil];
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
    NSLog(@"what is gmailUser: %@",[EmailService instance].imapSession.gmailUserDisplayName);
    if (indexPath.row == 0) cell.menuLabel.text = [EmailService instance].imapSession.username;
    else cell.menuLabel.text = [listArray objectAtIndex:indexPath.row];
    cell.menuLabel.backgroundColor = CLEAR_COLOR;
    cell.menuLabel.textColor = WHITE_CLR;
    cell.menuLabel.highlightedTextColor = UIColorFromRGB(0x1B8EEE);
    
    cell.contentView.backgroundColor = CLEAR_COLOR;
    cell.backgroundColor = CLEAR_COLOR;
    cell.contentView.backgroundColor = CLEAR_COLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setAccessoryType:UITableViewCellAccessoryNone];
     
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
    MenuCell *tempCell = (MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"what is tempCell.text: %@",tempCell.menuLabel.text);
    if ([tempCell.menuLabel.text isEqualToString:@"Sent Mail"]) {
        NSLog(@"sent mail requested");
         //The following line is required to get to the emailTableVC in mainVC
         // [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject;
        
        //this is required to get to the navigation controller title
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Sent Mails";

        //((EmailsTableViewController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject).isSearching = YES;
         [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:SENT];
    }
    else if ([tempCell.menuLabel.text isEqualToString:@"Archive"]){
        NSLog(@"archive mail requested");
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Archive";
        AppDelegate *tempAppDelegate = APPDELEGATE;
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:tempAppDelegate.currentFunnelDS.funnelId top:2000];
    }
    else if ([tempCell.menuLabel.text isEqualToString:@"Trash"]){
        NSLog(@"trash mail requested");
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Trash";
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:TRASH];
    }
    else if ([tempCell.menuLabel.text isEqualToString:@"Inbox"]) {
        AppDelegate *tempAppDelegate = APPDELEGATE;
        NSMutableArray * filterArray = [[NSMutableArray alloc] init];
        filterArray = [[[FunnelService instance] allFunnels] mutableCopy];
        tempAppDelegate.currentFunnelString = [[(FunnelModel *)filterArray[indexPath.row] funnelName] lowercaseString];
        tempAppDelegate.currentFunnelDS = (FunnelModel *)filterArray[indexPath.row];
        [self.mainVCdelegate filterSelected:(FunnelModel *)filterArray[indexPath.row]];
    }
    else if ([tempCell.menuLabel.text isEqualToString:@"Funnl Alerts"]){
        NSLog(@"funl alert requested");
        
    }
    else if ([tempCell.menuLabel.text isEqualToString:@"Help/FAQs"]){
        NSLog(@" help/qafs requested");
    }
    else if ([tempCell.menuLabel.text isEqualToString:@"Send Feedback"]){
        NSLog(@" Feedback requested");
    }
    else if ([tempCell.menuLabel.text isEqualToString:@"Drafts"]){
        NSLog(@"Drafts mail requested");
        [(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].navigationItem.title = @"Drafts";
        [[EmailService instance]loadLastNMessages:50 withTableController:[(UINavigationController *)[(MMDrawerController *) self.parentViewController centerViewController] topViewController].childViewControllers.firstObject withFolder:DRAFTS];
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
