//
//  CreateFunnlViewController.m
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "CreateFunnlViewController.h"
#import "TextFieldCell.h"
#import "EmailService.h"
#import "FunnelService.h"
//#import "FilterModel.h"
//newly added by iauro001 on 10th June 2014
#import "FunnelModel.h"
#import "UIColor+HexString.h"
#import "FunnelService.h"
#import <Mixpanel/Mixpanel.h>
#import "CIOExampleAPIClient.h"
#import "CIOAuthViewController.h"
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import "WEPopoverContentViewController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"


@interface CreateFunnlViewController ()<CIOAuthViewController>
{
}
@end

@implementation CreateFunnlViewController
UITableView *autocompleteTableView;
NSMutableArray *emailArr,*searchArray;
@synthesize mainVCdelegate,isEdit,popoverController,poc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initBarbuttonItem
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

-(id)initTableViewWithSenders:(NSMutableDictionary*)sendersDictionary subjects:(NSMutableDictionary*)subjectsDictionary filterModel:(FunnelModel*)model;
{
    self = [super init];
    if (self) {
        // Custom initialization
        funnlName = @"";
        if(model){
            //edit
            funnlName = model.filterTitle;
            oldModel = model;
            isEdit = YES;
        }
        
        if(sendersDictionary)
            dictionaryOfConversations = [[NSMutableDictionary alloc] initWithDictionary:sendersDictionary];
        else
            dictionaryOfConversations = [[NSMutableDictionary alloc] init];
        
        if(subjectsDictionary)
            dictionaryOfSubjects = [[NSMutableDictionary alloc] initWithDictionary:subjectsDictionary];
        else
            dictionaryOfSubjects = [[NSMutableDictionary alloc] init];
        
        Tableview = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        [Tableview registerClass:[TextFieldCell class]
          forCellReuseIdentifier:@"TextFieldCell"];
        Tableview.frame = CGRectMake(0, 66, WIDTH, HEIGHT - 66);
        [Tableview setDataSource:self];
        [Tableview setDelegate:self];
        [self.view addSubview:Tableview];
        [Tableview setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        
        if(isEdit){
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 60)];
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
            [deleteButton setTitleColor:[UIColor colorWithHexString:@"#448DEC"] forState:UIControlStateNormal];
            [deleteButton setTitleColor:[UIColor colorWithHexString:@"#6F7683"] forState:UIControlStateHighlighted];
            [deleteButton setTitle:@"Delete Funnl" forState:UIControlStateNormal];
            [deleteButton.layer setBorderColor:[UIColor colorWithHexString:@"#448DEC"].CGColor];
            [deleteButton.layer setBorderWidth:1];
            [footerView addSubview:deleteButton];
            Tableview.tableFooterView = footerView;
            [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPopoverCellIndex = -1;
    tempAppDelegate = APPDELEGATE;
    [self.view addSubview:tempAppDelegate.progressHUD];
    [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
    isSkipAll = oldModel.skipFlag;
    areNotificationsEnabled = oldModel.notificationsFlag;
    randomColors = GRADIENT_ARRAY;
    self.title = @"Create Funnl";
//    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.6 alpha:0.4]];

    [self initBarbuttonItem];
    
    [self emailContact];
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 180)];
    [autocompleteTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    autocompleteTableView.tag = 1;
    [self.view addSubview:autocompleteTableView];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}



#pragma -
#pragma mark TableView Datasource & delegate Methods.

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 1){
        return searchArray.count;
    }
    else {
        if(section==0){
            return 1;
        }
        else if(section == 1){
            return dictionaryOfConversations.allKeys.count + 1;
        }
        else if(section == 2){
            return dictionaryOfSubjects.allKeys.count + 1;
        }
        else {
            return 1;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    NSString *sectionTitle = @"";
    if(tableView.tag == 1){
        sectionTitle = @"";
    }
    if(section==0){
        sectionTitle =  @"Name:";
    }
    else if(section == 1){
        sectionTitle =  @"Conversation With:";
    }
    else if(section == 2){
        sectionTitle =  @"Subject (Optional):";
    }
    else if(section == 3){
        sectionTitle =  [NSString stringWithFormat:@"Skip %@:",ALL_FUNNL];
    } else {
        sectionTitle = @"Enable Notifications:";
    }
    sectionHeader.font = [UIFont boldSystemFontOfSize:20];
    sectionHeader.textColor = [UIColor whiteColor];
    sectionHeader.backgroundColor = CLEAR_COLOR;
    sectionHeader.text = [NSString stringWithFormat:@"  %@",sectionTitle];
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == Tableview){
        return 40;
    }
    return  0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView.tag == 1)
        return 1;
    return 5;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;  {
//    if(tableView.tag == 1){
//        return nil;
//    }
//    if(section==0){
//        return @"Name:";
//    }
//    else if(section == 1){
//        return @"Conversation With:";
//    }
//    else if(section == 2){
//        return @"Subject (Optional):";
//    }
//    else if(section == 3){
//        return [NSString stringWithFormat:@"Skip %@:",ALL_FUNNL];
//    } else {
//        return @"Enable Notifications:";
//    }
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == autocompleteTableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        if(indexPath.row <= searchArray.count){
            cell.textLabel.text = [searchArray objectAtIndex:indexPath.row];
        }
        return cell;
    } else {
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell" forIndexPath:indexPath];
        //Resetting the reused Cell first and then updating it with new data below that
        [cell.thumbnailImageView setImage:[UIImage imageNamed:@"userimage-placeholder.png"]];
        cell.backgroundColor = CLEAR_COLOR;
        [cell setIsSwitchVisibleMode:NO];
        cell.textField.delegate = self;
        cell.textField.tag = indexPath.section;
        cell.textField.text = @"";
        cell.textField.placeholder = @"";
        cell.textLabel.text = @"";
        cell.switchButton.on = NO;
        [cell.addButton setImage:[UIImage imageNamed:@"addIcon_white.png"] forState:UIControlStateNormal];
        cell.addButton.tag = indexPath.row;
        cell.switchButton.tag = indexPath.section;
        //resetting cell finshes, set new data from here
        UIColor *color = [UIColor lightGrayColor];

        switch (indexPath.section) {
            case 0:
            {
                [cell.tapButton setHidden:YES];
                cell.textField.frame = CGRectMake(10, 2, 250, 40);
                [cell.addButton setHidden:YES];
                cell.textField.placeholder = @"Enter name";
                cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter name" attributes:@{NSForegroundColorAttributeName: color}];
                [cell.textField setText:funnlName];
                //newly added on 11th Aug
                [cell.thumbnailImageView setHidden:YES];
            }
                break;
            case 1:
            {
                [cell.tapButton setHidden:NO];
                cell.tapButton.tag = indexPath.row;
                [cell.tapButton addTarget:self action:@selector(emailPopUpClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.textField setFrame:CGRectMake(155, 2,250 - 45, 40)];
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                [cell.addButton addTarget:self action:@selector(addButtonPressedForConversation:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.textField.placeholder = @"Enter Email ID";
                cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Email ID" attributes:@{NSForegroundColorAttributeName: color}];

                if(indexPath.row != dictionaryOfConversations.allKeys.count && dictionaryOfConversations.allKeys.count > 0){
                    NSMutableArray *array = [[ContactService instance] retrieveContactWithEmail:[dictionaryOfConversations objectForKey:indexPath]];
                    
                    if (array.count > 0) {
                        if (![[(ContactModel*)[array objectAtIndex:0] name] isEqualToString:@"nil"] && ![[(ContactModel*)[array objectAtIndex:0] name] isEqualToString:@""]) {

                            cell.textField.text = [(ContactModel*)[array objectAtIndex:0] name];
                        }
                        else {
                            cell.textField.text = [dictionaryOfConversations objectForKey:indexPath];
                            [cell.tapButton setHidden:YES];
                        }
                    }
                    else {
                        cell.textField.text = [dictionaryOfConversations objectForKey:indexPath];
                        [cell.tapButton setHidden:YES];
                    }
                    if (array.count > 0) {
                        if (![[(ContactModel*)[array objectAtIndex:0] thumbnail] isEqualToString:@"nil"]) {
                            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[(ContactModel*)[array objectAtIndex:0] thumbnail]]];
                            [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
                            
                            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
                            fetcher.comment = [NSString stringWithFormat:@"%d",indexPath.row];
                            GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
                            [fetcher setAuthorizer:currentAuth];
                            [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
                        }
                    }
                    
                    array = nil;
                    
                    [cell.addButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
                    [cell.addButton addTarget:self action:@selector(cancelButtonPressedForConversation:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.thumbnailImageView setHidden:NO];
                    [cell.textField setUserInteractionEnabled:NO];
                }
                else {
                    [cell.tapButton setHidden:YES];
                    [cell.thumbnailImageView setHidden:YES];
                    [cell.textField setUserInteractionEnabled:YES];
                }
                cell.textField.frame = CGRectMake(55, 2,250 - 45, 40);
            }
                break;
            case 2:
            {
                [cell.tapButton setHidden:YES];
                cell.textField.frame = CGRectMake(10, 2, 250, 40);
                [cell.thumbnailImageView setHidden:YES];
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                [cell.addButton addTarget:self action:@selector(addButtonPressedForSubject:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.textField.placeholder = @"Enter Subject";
                cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Subject" attributes:@{NSForegroundColorAttributeName: color}];

                if(indexPath.row != dictionaryOfSubjects.allKeys.count && dictionaryOfSubjects.allKeys.count > 0){
                    cell.textField.text = [dictionaryOfSubjects objectForKey:indexPath];
                    [cell.addButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
                    [cell.addButton addTarget:self action:@selector(cancelButtonPressedForSubject:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
                break;
            case 3:
            {
                [cell.tapButton setHidden:YES];
                [cell.thumbnailImageView setHidden:YES];
                [cell setIsSwitchVisibleMode:YES];
                cell.textLabel.text = [NSString stringWithFormat:@"Skip %@",ALL_FUNNL];
                cell.textLabel.textColor = WHITE_CLR;
                [cell.switchButton setOn:isSkipAll];
                [cell.switchButton addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            }
                break;
            case 4:
            {
                [cell.tapButton setHidden:YES];
                [cell.thumbnailImageView setHidden:YES];
                [cell setIsSwitchVisibleMode:YES];
                cell.textLabel.text = [NSString stringWithFormat:@"Enable Notifications"];
                cell.textLabel.textColor = WHITE_CLR;
                [cell.switchButton setOn:areNotificationsEnabled];
                [cell.switchButton addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            }
                break;
                
            default:
                break;
        }
/*        if(indexPath.section == 0)
        {
            cell.textField.frame = CGRectMake(10, 2,250, 40);
            cell.textField.placeholder = @"Enter name";
            cell.textField.text = funnlName;
            cell.textField.delegate = self;
            cell.textField.tag = indexPath.section;
            cell.tag = cell.contentView.tag = indexPath.row;
            cell.addButton.hidden = YES;
        }
        else if (indexPath.section == 1)
        {
            cell.textField.frame = CGRectMake(10, 2,250, 40);
            cell.textField.tag = indexPath.section;
            cell.textField.delegate = self;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            if(indexPath.row != dictionaryOfConversations.allKeys.count && dictionaryOfConversations.allKeys.count > 0){
                cell.textField.text = [dictionaryOfConversations objectForKey:indexPath];
            }
            
            if(indexPath.row ==  dictionaryOfConversations.allKeys.count)
            {
                [cell.addButton setHidden:NO];
                [cell.cancelButton setHidden:YES];
                [cell.addButton setFrame:CGRectMake(270, 2, 40, 40)];
                [cell.addButton addTarget:self action:@selector(addButtonPressedForConversation:) forControlEvents:UIControlEventTouchUpInside];
                cell.textField.placeholder = @"Enter Email ID";
            }else{
                [cell.addButton setHidden:YES];
                [cell.cancelButton setHidden:NO];
                [cell.cancelButton setFrame:CGRectMake(270, 2, 40, 40)];
                cell.cancelButton.tag = indexPath.row;
                [cell.cancelButton addTarget:self action:@selector(cancelButtonPressedForConversation:) forControlEvents:UIControlEventTouchUpInside];
            }
            cell.tag = cell.contentView.tag = indexPath.row;
        }
        else if (indexPath.section == 2)
        {
            cell.textField.frame = CGRectMake(10, 2,250, 40);
            cell.textField.tag = indexPath.section;
            cell.textField.delegate = self;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            if(indexPath.row != dictionaryOfSubjects.count && dictionaryOfSubjects.count > 0){
                cell.textField.text = [dictionaryOfSubjects objectForKey:indexPath];
            }
            if(indexPath.row == dictionaryOfSubjects.allKeys.count)
            {
                [cell.addButton setHidden:NO];
                [cell.cancelButton setHidden:YES];
                [cell.addButton setFrame:CGRectMake(270, 2, 40, 40)];
                [cell.addButton addTarget:self action:@selector(addButtonPressedForSubject:) forControlEvents:UIControlEventTouchUpInside];
                cell.textField.placeholder = @"Enter Subject";
            }
            else{
                [cell.addButton setHidden:YES];
                [cell.cancelButton setHidden:NO];
                [cell.cancelButton setFrame:CGRectMake(270, 2, 40, 40)];
                cell.cancelButton.tag = indexPath.row;
                [cell.cancelButton addTarget:self action:@selector(cancelButtonPressedForSubject:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            cell.tag = cell.contentView.tag = indexPath.row;
        }
        else if (indexPath.section == 3) {
            [cell setIsSwitchVisibleMode:YES];
            cell.textLabel.text = [NSString stringWithFormat:@"Skip %@",ALL_FUNNL];
//            skipAllSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 235, 0, 0)];
            if (oldModel.skipFlag) {
                [cell.switchButton setOn:YES];
            }
            else {
                [cell.switchButton setOn:NO];
            }
            [cell.switchButton addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.section == 4) {
            [cell setIsSwitchVisibleMode:YES];
            cell.textLabel.text = [NSString stringWithFormat:@"Enable Notifications"];
            [cell.switchButton setOn:oldModel.notificationsFlag ? YES : NO];
            [cell.switchButton addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        } */
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag == 1)
        return 40;
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissPopUp];
    if(tableView.tag == 1){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *temp = cell.textLabel.text;
        NSLog(@"description: %ld",(long)cell.textLabel.text);
        cell = [Tableview cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:1]];
        cell.textLabel.text = temp;
        if(activeField){
            activeField.text  = temp;
            [activeField resignFirstResponder];
            CGPoint textFieldOrigin = [Tableview convertPoint:activeField.bounds.origin fromView:activeField];
            NSIndexPath *indexPath = [Tableview indexPathForRowAtPoint:textFieldOrigin];
            if(activeField.text.length)
                [dictionaryOfConversations setObject:[activeField.text lowercaseString] forKey:indexPath];
            [Tableview reloadData];
        }
        NSLog(@"description2: %@",cell);
        temp = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        autocompleteTableView.hidden = YES;
        
    }
    else{
        NSLog(@"how often did i select a row");
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.section == 1){
            [dictionaryOfConversations removeObjectForKey:indexPath];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
            NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
            NSArray *sortedRows = [dictionaryOfConversations.allKeys sortedArrayUsingDescriptors:@[rowDescriptor]];
            //NSLog(@"%@",sortedRows.description);
            NSMutableDictionary *tmpDictionary = [[NSMutableDictionary alloc] init];
            NSInteger count = 0;
            for (NSIndexPath *path in sortedRows) {
                [tmpDictionary setObject:[dictionaryOfConversations objectForKey:path] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
                count++;
            }
            dictionaryOfConversations = [NSMutableDictionary dictionaryWithDictionary:tmpDictionary];
            tmpDictionary = nil;
        }
        else if(indexPath.section == 2){
            [dictionaryOfSubjects removeObjectForKey:indexPath];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
            NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
            NSArray *sortedRows = [dictionaryOfSubjects.allKeys sortedArrayUsingDescriptors:@[rowDescriptor]];
            //NSLog(@"%@",sortedRows.description);
            NSMutableDictionary *tmpDictionary = [[NSMutableDictionary alloc] init];
            NSInteger count = 0;
            for (NSIndexPath *path in sortedRows) {
                [tmpDictionary setObject:[dictionaryOfSubjects objectForKey:path] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
                count++;
            }
            dictionaryOfSubjects = [NSMutableDictionary dictionaryWithDictionary:tmpDictionary];
            tmpDictionary = nil;
        }
    }
    [activeField resignFirstResponder];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        if(dictionaryOfConversations.count > 0 && indexPath.row < dictionaryOfConversations.count ){
            return YES;
        }
        return NO;
    }
    else  if(indexPath.section == 2){
        if(dictionaryOfSubjects.count > 0 && indexPath.row < dictionaryOfSubjects.count ){
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    [self dismissPopUp];
}

#pragma mark -
#pragma mark GTMFetcherAuthorizationProtocol
- (void)imageFetcher:(GTMHTTPFetcher *)imageFetcher finishedWithData:(NSData *)imageData error:(NSError *)error {
    if (error) {
        
    }
    else {
        NSLog(@"--------> %@",imageFetcher.comment);
        TextFieldCell *tempCell = (TextFieldCell*)[Tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[imageFetcher.comment integerValue] inSection:1]];
        [tempCell.thumbnailImageView setImage:[UIImage imageWithData:imageData]];
    }
}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

#pragma mark -
#pragma mark Helper

- (void)dismissPopUp {
    if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
		currentPopoverCellIndex = -1;
	}
}

- (void)emailPopUpClicked:(UIButton*)sender {
//    UIViewController *detailsViewController = [[CreateFunnlViewController alloc] initWithNibName:@"CreateFunnlViewController" bundle:nil];
//    self.poc = [[UIPopoverController alloc] initWithContentViewController:detailsViewController];
//    [self.poc setDelegate:self];
//    [self.poc presentPopoverFromRect:[Tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:1]].frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    BOOL shouldShowNewPopover = sender.tag != currentPopoverCellIndex;
    
    if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
		currentPopoverCellIndex = -1;
	}
    
    if (shouldShowNewPopover) {
		WEPopoverContentViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
        NSMutableArray *array = [[ContactService instance] retrieveContactWithEmail:[dictionaryOfConversations objectForKey:[NSIndexPath indexPathForRow:sender.tag inSection:1]]];
        if (array.copy > 0) {
//            contentViewController.emailAddress = @"shrini@iauro.com";
            contentViewController.emailAddress = [(ContactModel*)[array objectAtIndex:0] email];
        }
		CGRect frame = [Tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:1]].frame;
		CGRect rect = frame;
		self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		
		if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
			[self.popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
		}
		
		self.popoverController.delegate = self;
		self.popoverController.passthroughViews = [NSArray arrayWithObject:Tableview];
		
		[self.popoverController presentPopoverFromRect:rect
												inView:Tableview
							  permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown|
														UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight)
											  animated:YES];
		currentPopoverCellIndex = sender.tag;
		
		contentViewController = nil;
	}
    
//    TextFieldCell *tempCell = (TextFieldCell*)[Tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:1]];
    NSLog(@"-----> button on %d row on section 1 clicked",sender.tag);
    
}

- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [WEPopoverContainerViewProperties alloc];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;
}

- (void)enableNotifications:(UISwitch*)sender {
    if([sender isOn]){
        NSLog(@"Switch is ON");
        areNotificationsEnabled = TRUE;
    } else{
        NSLog(@"Switch is OFF");
        areNotificationsEnabled = FALSE;
    }
}


-(void) changeNotificationSwitch:(UISwitch *)sender
{
    areNotificationsEnabled = sender.on;
    if (areNotificationsEnabled) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (![appDelegate.contextIOAPIClient isAuthorized]) {
            CIOAuthViewController *authViewController = [[CIOAuthViewController alloc] initWithAPIClient:[CIOExampleAPIClient sharedClient] allowCancel:YES];
            authViewController.delegate = self;
            UINavigationController *authNavController = [[UINavigationController alloc] initWithRootViewController:authViewController];
            [self presentViewController:authNavController animated:YES completion:nil];
        }
    }
}

- (void)changeSwitch:(UISwitch*)sender {
    [self dismissPopUp];
    switch (sender.tag) {
        case 3:
            isSkipAll = sender.on;
            break;
        case 4:
            [self changeNotificationSwitch:sender];
            break;
        default:
            break;
    }
}

- (void)decrementCounterAgainstTheMessage {
    NSArray *messageArray = [[MessageFilterXRefService instance] messagesWithFunnelId:oldModel.funnelId];
    for (MessageModel *tempModel in messageArray) {
        tempModel.skipFlag --;
        [[MessageService instance] updateMessage:tempModel];
    }
}

- (void)incrementCounterAgainstTheMessage {
    NSArray *messageArray = [[MessageFilterXRefService instance] messagesWithFunnelId:oldModel.funnelId];
    for (MessageModel *tempModel in messageArray) {
        tempModel.skipFlag++;
        [[MessageService instance] updateMessage:tempModel];
    }
}

#pragma mark -  Add Subject/Conversation Button Methods


-(void)addButtonPressedForConversation:(UIButton *)sender
{
    CGPoint buttonOrigin = [Tableview convertPoint:sender.bounds.origin fromView:sender];
    NSIndexPath *indexPath = [Tableview indexPathForRowAtPoint:buttonOrigin];
    TextFieldCell *cell = (TextFieldCell*)[Tableview cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField*)[cell viewWithTag:indexPath.section];
    [textField becomeFirstResponder];
    [textField resignFirstResponder];
    [Tableview reloadData];
}

-(void)addButtonPressedForSubject:(UIButton *)sender
{
    CGPoint buttonOrigin = [Tableview convertPoint:sender.bounds.origin fromView:sender];
    NSIndexPath *indexPath = [Tableview indexPathForRowAtPoint:buttonOrigin];
    TextFieldCell *cell = (TextFieldCell*)[Tableview cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField*)[cell viewWithTag:indexPath.section];
    [textField becomeFirstResponder];
    [textField resignFirstResponder];
    [Tableview reloadData];
}

-(void)cancelButtonPressedForConversation:(id)sender{
    UIButton *b = (UIButton*)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:b.tag inSection:1];
    
    [dictionaryOfConversations removeObjectForKey:indexPath];
    NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
    NSArray *sortedRows = [dictionaryOfConversations.allKeys sortedArrayUsingDescriptors:@[rowDescriptor]];
    //NSLog(@"%@",sortedRows.description);
    NSMutableDictionary *tmpDictionary = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    for (NSIndexPath *path in sortedRows) {
        [tmpDictionary setObject:[dictionaryOfConversations objectForKey:path] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
        count++;
    }
    dictionaryOfConversations = [NSMutableDictionary dictionaryWithDictionary:tmpDictionary];
    [Tableview reloadData];
    tmpDictionary = nil;
}

-(void)cancelButtonPressedForSubject:(id)sender{
    UIButton *b = (UIButton*)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:b.tag inSection:2];
    [dictionaryOfSubjects removeObjectForKey:indexPath];
    NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
    NSArray *sortedRows = [dictionaryOfSubjects.allKeys sortedArrayUsingDescriptors:@[rowDescriptor]];
    //NSLog(@"%@",sortedRows.description);
    NSMutableDictionary *tmpDictionary = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    for (NSIndexPath *path in sortedRows) {
        [tmpDictionary setObject:[dictionaryOfSubjects objectForKey:path] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
        count++;
    }
    dictionaryOfSubjects = [NSMutableDictionary dictionaryWithDictionary:tmpDictionary];
    [Tableview reloadData];
    tmpDictionary = nil;
}



-(void)deleteButtonClicked:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *webhookJSONString = [oldModel webhookIds];
    NSData *jsonData = [webhookJSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *webhooks = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSArray *senders = [[webhooks allKeys] copy];
    __block int reqCnt = [senders count];
    for (NSString *sender in senders) {
        NSDictionary *webhook_id_Dictionary = [webhooks objectForKey:sender];
        NSString *webhook_id = [webhook_id_Dictionary objectForKey:@"webhook_id"];
        [appDelegate.contextIOAPIClient deleteWebhookWithID:webhook_id success:^(NSDictionary *responseDict) {
            NSLog(@"responseDict deletion %@",responseDict);
            [webhooks removeObjectForKey:webhook_id];
            reqCnt--;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (reqCnt == 0) {
                    [self deleteOperation];
                }
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            reqCnt--;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"deleteButtonClicked --- deleteWebhookWithID : %@",error.userInfo.description);
                //[self showAlertForError:error];
                if (reqCnt == 0) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }
            });
        }];
    }
    [[Mixpanel sharedInstance] track:@"Funnl deleteButton pressed"];
}

- (void)deleteOperation {
    if (oldModel.skipFlag) {
        [[MessageFilterXRefService instance] deleteXRefWithFunnelId:oldModel.funnelId];
        [self decrementCounterAgainstTheMessage];
    }
    [[FunnelService instance] deleteFunnel:oldModel.funnelId];
    [[MessageService instance] insertFunnelJsonForMessages];
    [tempAppDelegate.progressHUD show:YES];
    [tempAppDelegate.progressHUD removeFromSuperview];
    NSArray *funnelArray = [[FunnelService instance] allFunnels];
    tempAppDelegate.currentFunnelString = [[(FunnelModel *)funnelArray[0] funnelName] lowercaseString];
    tempAppDelegate.currentFunnelDS = (FunnelModel *)funnelArray[0];
    [self.mainVCdelegate filterSelected:(FunnelModel *)funnelArray[0]];
    funnelArray = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetFunnelJsonInMessage {
    
}

- (void)tempFunction {
    [tempAppDelegate.progressHUD show:YES];
    [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
}

- (int)validateFunnelName:(NSString*)funnelName {
    NSArray *funnelArray = [[FunnelService instance] allFunnels];
    for (FunnelModel *tempFunnelName in funnelArray) {
        if ([tempFunnelName.funnelName.lowercaseString isEqualToString:funnelName.lowercaseString]) {
            return 2;
        }
    }
    if ([[funnelName stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {
        return 3;
    }
    return 1;
}


-(void) saveFunnlWithWebhookId:(NSString *) webhookId
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(webhookId != nil){
        //---- Added by Krunal to get work PNs
        NSData* jsonData = [webhookId dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *webhooks = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
        NSArray *senders = [[webhooks allKeys] copy];
        NSMutableArray *webhookChannelArray = [NSMutableArray new];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        for (NSString *sender in senders) {
            NSDictionary *webhook_id_Dictionary = [webhooks objectForKey:sender];
            NSString *webhook_id = [webhook_id_Dictionary objectForKey:@"webhook_id"];
            [webhookChannelArray addObject:webhook_id];
            [currentInstallation addUniqueObject:([NSString stringWithFormat:@"webhook_id_%@", webhook_id]) forKey:@"channels"];
        }
        [currentInstallation saveInBackground];
        //---- end
    }
    else{
        
    }
    
    
    unsigned long temp = [[FunnelService instance] allFunnels].count%8;
    //NSInteger gradientInt = arc4random_uniform((uint32_t)randomColors.count);
    UIColor *color = [UIColor colorWithHexString:[randomColors objectAtIndex:temp]];
    if(color == nil){
        color = [UIColor colorWithHexString:@"#2EB82E"];
    }
    FunnelModel *model;
    model = [[FunnelModel alloc]initWithBarColor:color filterTitle:funnlName newMessageCount:0 dateOfLastMessage:[NSDate new] sendersArray:[NSMutableArray arrayWithArray:[dictionaryOfConversations allValues]] subjectsArray:(NSMutableArray*)[dictionaryOfSubjects allValues] skipAllFlag:isSkipAll funnelColor:[randomColors objectAtIndex:temp]];
    model.funnelId = oldModel.funnelId;
    model.notificationsFlag = areNotificationsEnabled;
    model.webhookIds = webhookId ? webhookId : @"";
    tempAppDelegate.currentFunnelString = model.funnelName.lowercaseString;
    tempAppDelegate.currentFunnelDS = model;
    model.skipFlag = isSkipAll;
    
    if(isEdit){
        //                [EmailService editFilter:model withOldFilter:oldModel];
        // save to db
        
        [[MessageFilterXRefService instance] deleteXRefWithFunnelId:model.funnelId];
        [[FunnelService instance] updateFunnel:model];
        [[EmailService instance] applyingFunnel:model toMessages:[[MessageService instance] messagesAllTopMessages]];
        
        if (oldModel.skipFlag == isSkipAll) {
            NSLog(@"No changes had occured!!");
        }
        else {
            if (isSkipAll) {
                [self incrementCounterAgainstTheMessage];
            }
            else {
                [self decrementCounterAgainstTheMessage];
            }
            NSLog(@"Changes had occured!!");
        }
        [[MessageService instance] insertFunnelJsonForMessages];
    }else{
        [[FunnelService instance] insertFunnel:model];
        [[EmailService instance] applyingFunnel:model toMessages:[[MessageService instance] messagesAllTopMessages]];
        if (isSkipAll) {
            //                    [self incrementCounterAgainstTheMessage];
        }
        else {
            
        }
        [EmailService setNewFilterModel:model];
        // save to db
        
    }
    [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:model.funnelId top:2000];
    [self.mainVCdelegate filterSelected:model];
    model = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //[[CIOExampleAPIClient sharedClient] clearCredentials];
    [self.navigationController popViewControllerAnimated:YES];
}



-(void) showAlertForError:(NSError *) error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}


-(void) createWebhooksAndSaveFunnl
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray *senders = [dictionaryOfConversations allValues];
    NSArray *subjects = [dictionaryOfSubjects allValues];
    __block int reqCnt = [senders count];
    if ([subjects count]) {
        reqCnt *= [subjects count];
    }
    NSMutableDictionary *webhooks = [[NSMutableDictionary alloc] init];
    //creation of webhooks
    for (NSString *sender in senders) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:sender forKey:@"filter_from"];
        //[params setObject:@"0" forKey:@"sync_period"];
        if ([subjects count]) {
            for (NSString *subject in subjects) {
                [params setObject:subject forKey:@"filter_subject"];
                [appDelegate.contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
                    [webhooks setObject:responseDict forKey:sender];
                    reqCnt--;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (reqCnt == 0) {
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:webhooks options:NSJSONWritingPrettyPrinted error:nil];
                            NSString *webhookIds = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            [self saveFunnlWithWebhookId:webhookIds];
                        }
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    reqCnt--;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
                        //[self showAlertForError:error];
                        if (reqCnt == 0) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                    });
                }];
                continue;
            }
        } else {
            [appDelegate.contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
                [webhooks setObject:responseDict forKey:sender];
                reqCnt--;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (reqCnt == 0) {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:webhooks options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *webhookIds = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [self saveFunnlWithWebhookId:webhookIds];
                    }
                });
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                reqCnt--;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"createWebhooksAndSaveFunnl --- Email : %@",error.userInfo.description);
                    //[self showAlertForError:error];
                    if (reqCnt == 0) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [self saveFunnlWithWebhookId:nil];
                    }
                });
            }];
        }
    }
}

-(void)saveButtonPressed
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"Save Butoon pressed");
    [[Mixpanel sharedInstance] track:@"Funnl Save Button pressed"];
    if(activeField){
        [activeField resignFirstResponder];
    }
    if(funnlName.length){
        int validCode = [self validateFunnelName:funnlName];
        if (validCode != 1 && !isEdit) {
            if (validCode == 2) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FUNNEL_NAME_REPEATED message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            else if (validCode == 3) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FUNNEL_NAME_BLANK message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            return;
        }

        if(dictionaryOfConversations.allKeys.count){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if (!areNotificationsEnabled) {
                [self saveFunnlWithWebhookId:nil];
            } else {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                if (oldModel != nil && [oldModel.webhookIds length]) {
                    NSString *webhookJSONString = [oldModel webhookIds];
                    NSData *jsonData = [webhookJSONString dataUsingEncoding:NSUTF8StringEncoding];
                    NSMutableDictionary *webhooks = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
                    NSArray *senders = [[webhooks allKeys] copy];
                    __block int reqCnt = [senders count];
                    for (NSString *sender in senders) {
                        NSDictionary *webhook_id_Dictionary = [webhooks objectForKey:sender];
                        NSString *webhook_id = [webhook_id_Dictionary objectForKey:@"webhook_id"];
                        [appDelegate.contextIOAPIClient deleteWebhookWithID:webhook_id success:^(NSDictionary *responseDict) {
                            NSLog(@"responseDict deletion %@",responseDict);
                            [webhooks removeObjectForKey:webhook_id];
                            reqCnt--;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (reqCnt == 0) {
                                    [self createWebhooksAndSaveFunnl];
                                }
                            });
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            reqCnt--;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //[self showAlertForError:error];
                                NSLog(@"saveButtonPressed --- deleteWebhookWithID : %@",error.userInfo.description);
                                if (reqCnt == 0) {
                                    [self createWebhooksAndSaveFunnl];
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                }
                            });
                        }];
                    }
                } else {
                    [self createWebhooksAndSaveFunnl];
                }
                
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Please add at least one email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Please add name for Funnl" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    [tempAppDelegate.progressHUD setHidden:YES];
    [tempAppDelegate.progressHUD removeFromSuperview];
}


#pragma mark - CIOAuthViewController delegate

- (void)userCompletedLogin
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)userCancelledLogin
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    // Put anything that starts with this substring into the searchArray
    // The items in this array is what will show up in the table view
    [searchArray removeAllObjects];
    if(substring.length){
        emailArr = [[NSMutableArray alloc] initWithArray:[[ContactService instance] searchContactsWithString:substring]];
        for(NSMutableString *curString in emailArr) {
            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([curString rangeOfString:substring].location == 0) {
                [searchArray addObject:curString];
            }
        }
    }
    if(searchArray.count <= 0){
        autocompleteTableView.hidden = YES;
    }
    else{
        autocompleteTableView.hidden = NO;
        //dispatch_async(dispatch_get_main_queue(), ^{
            [autocompleteTableView reloadData];
        //});
    }
}

#pragma mark - TextField delegate



- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag != 1) return YES;
    [self.view bringSubviewToFront:autocompleteTableView];
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    if(searchArray.count != 0) autocompleteTableView.hidden = NO;
    else autocompleteTableView.hidden = YES;
    return YES;
}


CGRect temp;//this is necessary to reset view
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self dismissPopUp];
    activeField = textField;
    if (textField.tag == 1) {
        NSLog(@"Entered Email ID");
        CGFloat height = (CGFloat)(80+(dictionaryOfConversations.allKeys.count+1)*40);
        NSLog(@"this is the height: %f",height);
        //temp = self.view.frame;
        //self.view.frame = CGRectMake(0, -height, 480, self.view.bounds.size.height+height);
        TextFieldCell *cell = [(TextFieldCell*)[textField superview] superview];
        NSIndexPath *indexPath = [Tableview indexPathForCell:cell];
        CGRect myRect = [Tableview rectForRowAtIndexPath:indexPath];
        //myRect = [Tableview convertRect:cell.frame toView:self.view];
        [Tableview scrollRectToVisible:CGRectMake(Tableview.frame.origin.x, myRect.origin.y-120, 1, 1) animated:YES];
    

        Tableview.scrollEnabled = NO;
    }
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;{
    if(textField.tag == 0){
        funnlName = textField.text;
    }
    else if(textField.tag == 1){
        Tableview.scrollEnabled = YES;
        NSLog(@"is ending");
        autocompleteTableView.hidden = YES;
        CGPoint textFieldOrigin = [Tableview convertPoint:textField.bounds.origin fromView:textField];
        NSIndexPath *indexPath = [Tableview indexPathForRowAtPoint:textFieldOrigin];
        if(textField.text.length)
            [dictionaryOfConversations setObject:[textField.text lowercaseString] forKey:indexPath];
        //self.view.frame = CGRectMake(0, 0, 480, self.view.bounds.size.height-(CGFloat)(80+(dictionaryOfConversations.allKeys.count+1)*40));
    }
    else if(textField.tag == 2){
        CGPoint textFieldOrigin = [Tableview convertPoint:textField.bounds.origin fromView:textField];
        NSIndexPath *indexPath = [Tableview indexPathForRowAtPoint:textFieldOrigin];
        if(textField.text.length)
            [dictionaryOfSubjects setObject:[textField.text lowercaseString] forKey:indexPath];
    }
    //[Tableview reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"did return");
    [textField resignFirstResponder];
    [Tableview reloadData];
    return YES;
}

#pragma mark -
- (void)keyboardWillShow:(NSNotification *)sender
{
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(50, 0, kbSize.height, 0);
        [Tableview setContentInset:edgeInsets];
        [Tableview setScrollIndicatorInsets:edgeInsets];
    }];
    CGRect keyboardRect = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    autocompleteTableView.frame = CGRectMake(autocompleteTableView.frame.origin.x,_keyboardHeight-150,autocompleteTableView.frame.size.width,155.0);

}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(50, 0, 0, 0);;
        [Tableview setContentInset:edgeInsets];
        [Tableview setScrollIndicatorInsets:edgeInsets];
    }];
    _keyboardHeight = 0;
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)emailContact

{
    
    emailArr = [[NSMutableArray alloc]init];
    searchArray = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                
                CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
                NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(people)];
                for (CFIndex i = 0; i < CFArrayGetCount(people); i++)
                {
                    ABRecordRef person = CFArrayGetValueAtIndex(people, i);
                    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                    for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++)
                    {
                        NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                        [allEmails addObject:email];
                        
                    }
                    CFRelease(emails);
                }
                emailArr = allEmails;
                
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(people)];
        for (CFIndex i = 0; i < CFArrayGetCount(people); i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++)
            {
                NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                if([self validateEmail:email]) [allEmails addObject:email];
                
            }
            CFRelease(emails);
        }
        emailArr = allEmails;
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
    
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


@end
