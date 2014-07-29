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
//#import "FilterModel.h"
//newly added by iauro001 on 10th June 2014
#import "FunnelModel.h"
#import "UIColor+HexString.h"
#import "FunnelService.h"
#import <Mixpanel/Mixpanel.h>
#import <AddressBook/AddressBook.h>

@interface CreateFunnlViewController ()

@end

@implementation CreateFunnlViewController
UITableView *autocompleteTableView;
NSMutableArray *emailArr,*searchArray;
@synthesize mainVCdelegate,isEdit;

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
        Tableview.frame = CGRectMake(0, 66, WIDTH, HEIGHT - 66);
        [Tableview setDataSource:self];
        [Tableview setDelegate:self];
        [self.view addSubview:Tableview];
        
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
    tempAppDelegate = APPDELEGATE;
    [self.view addSubview:tempAppDelegate.progressHUD];
    [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
    isSkipAll = oldModel.skipFlag;
    randomColors = GRADIENT_ARRAY;
    self.title = @"Create Funnl";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initBarbuttonItem];
    
    [self emailContact];
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 180)];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    autocompleteTableView.tag = 1;
   // [self.view addSubview:autocompleteTableView];
    
    
    
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
            return dictionaryOfConversations.allKeys.count+1;
        }
        else if(section == 2){
            return dictionaryOfSubjects.allKeys.count+1;
        }
        else {
            return 1;
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView.tag == 1) return 1;
    return 4;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;  {
    if(tableView.tag == 1){
        return nil;
    }
    if(section==0){
        return @"Name:";
    }
    else if(section == 1){
        return @"Conversation With:";
    }
    else if(section == 2){
        return @"Subject (Optional):";
    }
    else {
        return [NSString stringWithFormat:@"Skip %@:",ALL_FUNNL];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 1){
        UITableViewCell *cell = nil;
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
        }
        
        cell.textLabel.text = [searchArray objectAtIndex:indexPath.row];
        return cell;
    }
    else {
        if (indexPath.section == 3) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = [NSString stringWithFormat:@"Skip %@",ALL_FUNNL];
            skipAllSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(300-50, 8, 50, 0)];
            if (oldModel.skipFlag) {
                [skipAllSwitch setOn:YES];
            }
            else {
                [skipAllSwitch setOn:NO];
            }
            [skipAllSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:skipAllSwitch];
            return cell;
        }
        TextFieldCell *cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        if(indexPath.section == 0)
        {
            cell.textField.frame = CGRectMake(10, 2,250, 40);
            cell.textField.placeholder = @"Enter name";
            cell.textField.text = funnlName;
            cell.textField.delegate = self;
            cell.textField.tag = indexPath.section;
            cell.tag = cell.contentView.tag = indexPath.row;
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
            skipAllSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 235, 0, 0)];
            if (oldModel.skipFlag) {
                [skipAllSwitch setOn:YES];
            }
            else {
                [skipAllSwitch setOn:NO];
            }
            [skipAllSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:skipAllSwitch];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag == 1) return 60;
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 1){
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        NSString *temp = cell.textLabel.text;
//        NSLog(@"description: %ld",(long)cell.textLabel.text);
//        cell = [Tableview cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:1]];
//        cell.textLabel.text = temp;
//        NSLog(@"description2: %@",cell);
//        temp = nil;
//        [tableView deselectRowAtIndexPath:indexPath animated:NO];
//        autocompleteTableView.hidden = YES;
        
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

#pragma mark -
#pragma mark Helper
- (void)changeSwitch:(UISwitch*)sender {
    if([sender isOn]){
        NSLog(@"Switch is ON");
        isSkipAll = TRUE;
    } else{
        NSLog(@"Switch is OFF");
        isSkipAll = FALSE;
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
    [Tableview deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
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
    [Tableview deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
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

-(void)deleteButtonClicked:(id)sender{
//    [self.view addSubview:tempAppDelegate.progressHUD];
//    [tempAppDelegate.progressHUD show:YES];
//    [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
//    [NSThread sleepForTimeInterval:0.2];
//    [self performSelector:@selector(deleteOperation) withObject:nil afterDelay:0.1];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //load your data here.
//        [self.view addSubview:tempAppDelegate.progressHUD];
//        [tempAppDelegate.progressHUD show:YES];
        [tempAppDelegate.progressHUD setHidden:NO];
        [self performSelectorInBackground:@selector(tempFunction) withObject:nil];
//        [self.view bringSubviewToFront:tempAppDelegate.progressHUD];
//        [NSThread sleepForTimeInterval:0.1];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            //update UI in main thread.
            [tempAppDelegate.progressHUD setHidden:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
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

-(void)saveButtonPressed
{
    [tempAppDelegate.progressHUD setHidden:NO];
    [self performSelectorInBackground:@selector(tempFunction) withObject:nil];
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
                [tempAppDelegate.progressHUD setHidden:YES];
            }
            else if (validCode == 3) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FUNNEL_NAME_BLANK message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
                [tempAppDelegate.progressHUD setHidden:YES];
            }
            return;
        }

        if(dictionaryOfConversations.allKeys.count){
            
            NSInteger gradientInt = arc4random_uniform((uint32_t)randomColors.count);
            UIColor *color = [UIColor colorWithHexString:[randomColors objectAtIndex:gradientInt]];
            if(color == nil){
                color = [UIColor colorWithHexString:@"#2EB82E"];
            }
            FunnelModel *model;
            model = [[FunnelModel alloc]initWithBarColor:color filterTitle:funnlName newMessageCount:0 dateOfLastMessage:[NSDate new] sendersArray:(NSMutableArray*)[dictionaryOfConversations allValues] subjectsArray:(NSMutableArray*)[dictionaryOfSubjects allValues] skipAllFlag:isSkipAll funnelColor:[randomColors objectAtIndex:gradientInt]];
            model.funnelId = oldModel.funnelId;
            FunnelModel *modelForFunnl = [[FunnelModel alloc] init];
            modelForFunnl.funnelName = model.filterTitle;
            tempAppDelegate.currentFunnelString = model.funnelName.lowercaseString;
            tempAppDelegate.currentFunnelDS = model;
            NSArray *tempArrayForSender = [dictionaryOfConversations allValues];
            NSMutableString *senderEmailIds = [[NSMutableString alloc] init];
            for (NSString *tempString in tempArrayForSender) {
                [senderEmailIds appendString:tempString];
                [senderEmailIds appendString:@","];
            }
            if (senderEmailIds.length > 0) {
                senderEmailIds = (NSMutableString*)[senderEmailIds substringWithRange:NSMakeRange(0, senderEmailIds.length-1)];
                modelForFunnl.emailAddresses = senderEmailIds;
            }
            else
                modelForFunnl.emailAddresses = @"";
            senderEmailIds = nil;
            tempArrayForSender = nil;
            
            tempArrayForSender = [dictionaryOfSubjects allValues];
            senderEmailIds = [[NSMutableString alloc] init];
            for (NSString *tempString in tempArrayForSender) {
                [senderEmailIds appendString:tempString];
                [senderEmailIds appendString:@","];
            }
            if (senderEmailIds.length > 0) {
                senderEmailIds = (NSMutableString*)[senderEmailIds substringWithRange:NSMakeRange(0, senderEmailIds.length-1)];
                modelForFunnl.phrases = senderEmailIds;
            }
            else
                modelForFunnl.phrases = @"";
            senderEmailIds = nil;
            tempArrayForSender = nil;
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
//            [[MessageService instance] insertFunnelJsonForMessages];
            [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:model.funnelId top:2000];
            [self.mainVCdelegate filterSelected:model];
            model = nil;
            modelForFunnl = nil;
            [self.navigationController popViewControllerAnimated:YES];
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

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the searchArray
    // The items in this array is what will show up in the table view
    [searchArray removeAllObjects];
    for(NSMutableString *curString in emailArr) {
        
        substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([curString rangeOfString:substring].location == 0) {
            [searchArray addObject:curString];
        }
        
    }
    [autocompleteTableView reloadData];
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField.tag != 1) return YES;
    [self.view bringSubviewToFront:autocompleteTableView];
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring
                 stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    if(searchArray.count != 0) autocompleteTableView.hidden = NO;
    else autocompleteTableView.hidden = YES;
    return YES;
}


CGRect temp;//this is necessary to reset view
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    activeField = textField;
    if (textField.tag == 1) {
        NSLog(@"Entered Email ID");
        CGFloat height = (CGFloat)(80+(dictionaryOfConversations.allKeys.count+1)*40);
        NSLog(@"this is the height: %f",height);
        //temp = self.view.frame;
        //self.view.frame = CGRectMake(0, -height, 480, self.view.bounds.size.height+height);
    }
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;{
    if(textField.tag == 0){
        funnlName = textField.text;
    }
    else if(textField.tag == 1){
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
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(50, 0, 0, 0);;
        [Tableview setContentInset:edgeInsets];
        [Tableview setScrollIndicatorInsets:edgeInsets];
    }];
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
