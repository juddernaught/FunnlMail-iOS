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

@interface CreateFunnlViewController ()

@end

@implementation CreateFunnlViewController
@synthesize mainVCdelegate;
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
    
    tableview = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [tableview setDataSource:self];
    [tableview setDelegate:self];
    [self.view addSubview:tableview];
    
    if(isEdit){
      UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
      UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
      [deleteButton setTitleColor:[UIColor colorWithHexString:@"#448DEC"] forState:UIControlStateNormal];
      [deleteButton setTitleColor:[UIColor colorWithHexString:@"#6F7683"] forState:UIControlStateHighlighted];
      [deleteButton setTitle:@"Delete Funnl" forState:UIControlStateNormal];
      [deleteButton.layer setBorderColor:[UIColor colorWithHexString:@"#448DEC"].CGColor];
      [deleteButton.layer setBorderWidth:1];
      [footerView addSubview:deleteButton];
      tableview.tableFooterView = footerView;
      [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
  }
  return self;
  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    randomColors = GRADIENT_ARRAY;
    self.title = @"Create Funnl";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initBarbuttonItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma -
#pragma mark TableView Datasource & delegate Methods.

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        return 1;
    }
    else if(section == 1){
        return dictionaryOfConversations.allKeys.count+1;
    }
    else{
        return dictionaryOfSubjects.allKeys.count+1;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;  {
    if(section==0){
        return @"Name:";
    }
    else if(section == 1){
        return @"Conversation With:";
    }
    else{
        return @"Subject (Optional):";
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    else
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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


#pragma mark -  Add Subject/Conversation Button Methods

-(void)addButtonPressedForConversation:(UIButton *)sender
{
    CGPoint buttonOrigin = [tableview convertPoint:sender.bounds.origin fromView:sender];
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:buttonOrigin];
    TextFieldCell *cell = (TextFieldCell*)[tableview cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField*)[cell viewWithTag:indexPath.section];
    [textField becomeFirstResponder];
    [textField resignFirstResponder];
    [tableview reloadData];
}

-(void)addButtonPressedForSubject:(UIButton *)sender
{
    CGPoint buttonOrigin = [tableview convertPoint:sender.bounds.origin fromView:sender];
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:buttonOrigin];
    TextFieldCell *cell = (TextFieldCell*)[tableview cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField*)[cell viewWithTag:indexPath.section];
    [textField becomeFirstResponder];
    [textField resignFirstResponder];
    [tableview reloadData];
}

-(void)cancelButtonPressedForConversation:(id)sender{
  UIButton *b = (UIButton*)sender;
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:b.tag inSection:1];

  [dictionaryOfConversations removeObjectForKey:indexPath];
  [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
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

-(void)cancelButtonPressedForSubject:(id)sender{
  UIButton *b = (UIButton*)sender;
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:b.tag inSection:2];
  
  [dictionaryOfSubjects removeObjectForKey:indexPath];
  [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
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
  [EmailService deleteFilter:oldModel];
  FunnelModel *defaultFilter = [EmailService getDefaultFilter];
  [self.mainVCdelegate filterSelected:defaultFilter];
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveButtonPressed
{
    NSLog(@"Save Butoon pressed");
  if(activeField){
        [activeField resignFirstResponder];
    }
    if(funnlName.length){
        if(dictionaryOfConversations.allKeys.count){
      
            NSInteger gradientInt = arc4random_uniform(randomColors.count);
            UIColor *color = [UIColor colorWithHexString: [randomColors objectAtIndex:gradientInt]];
            if(color == nil){
                color = [UIColor colorWithHexString:@"#2EB82E"];
            }
            FunnelModel *model;
            model = [[FunnelModel alloc]initWithBarColor:color filterTitle:funnlName newMessageCount:0 dateOfLastMessage:[NSDate new] sendersArray:(NSMutableArray*)[dictionaryOfConversations allValues] subjectsArray:(NSMutableArray*)[dictionaryOfSubjects allValues]];
            model.funnelId = oldModel.funnelId;
            FunnelModel *modelForFunnl = [[FunnelModel alloc] init];
            modelForFunnl.funnelName = model.filterTitle;
            
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
            
            if(isEdit){
//                [EmailService editFilter:model withOldFilter:oldModel];
                // save to db
                [[FunnelService instance] updateFunnel:model];
            }else{
                [EmailService setNewFilterModel:model];
                // save to db
                [[FunnelService instance] insertFunnel:model];
            }
            
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
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    activeField = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;{
    if(textField.tag == 0){
        funnlName = textField.text;
    }
    else if(textField.tag == 1){
        CGPoint textFieldOrigin = [tableview convertPoint:textField.bounds.origin fromView:textField];
        NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:textFieldOrigin];
        if(textField.text.length)
            [dictionaryOfConversations setObject:[textField.text lowercaseString] forKey:indexPath];
    }
    else if(textField.tag == 2){
        CGPoint textFieldOrigin = [tableview convertPoint:textField.bounds.origin fromView:textField];
        NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:textFieldOrigin];
        if(textField.text.length)
            [dictionaryOfSubjects setObject:[textField.text lowercaseString] forKey:indexPath];
    }
    [tableview reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [tableview reloadData];
    return YES;
}

#pragma mark - 
- (void)keyboardWillShow:(NSNotification *)sender
{
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(50, 0, kbSize.height, 0);
        [tableview setContentInset:edgeInsets];
        [tableview setScrollIndicatorInsets:edgeInsets];
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(50, 0, 0, 0);;
        [tableview setContentInset:edgeInsets];
        [tableview setScrollIndicatorInsets:edgeInsets];
    }];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
