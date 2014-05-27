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
#import "FilterModel.h"
#import "UIColor+HexString.h"

@interface CreateFunnlViewController ()

@end

@implementation CreateFunnlViewController

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

-(void)initTableView
{
    funnlName = @"";
    dictionaryOfConversations = [[NSMutableDictionary alloc] init];
    dictionaryOfSubjects = [[NSMutableDictionary alloc] init];
    tableview = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [tableview setDataSource:self];
    [tableview setDelegate:self];
    [self.view addSubview:tableview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    randomColors = GRADIENT_ARRAY;
    self.title = @"Create Funnl";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initBarbuttonItem];
    [self initTableView];
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
        cell.textField.frame = CGRectMake(10, 2,280, 40);
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
            [cell.addButton setFrame:CGRectMake(270, 2, 40, 40)];
            [cell.addButton addTarget:self action:@selector(addButtonPressedForConversation:) forControlEvents:UIControlEventTouchUpInside];
            cell.textField.placeholder = @"Enter Email ID";
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
            [cell.addButton setFrame:CGRectMake(270, 2, 40, 40)];
            [cell.addButton addTarget:self action:@selector(addButtonPressedForSubject:) forControlEvents:UIControlEventTouchUpInside];
            cell.textField.placeholder = @"Enter Subject";
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

-(void)saveButtonPressed
{
    if(activeField){
        [activeField resignFirstResponder];
    }
    NSLog(@"Save Butoon pressed");
    if(funnlName.length){
        if(dictionaryOfConversations.allKeys.count){
          NSInteger gradientInt = arc4random_uniform(randomColors.count);
          UIColor *color = [UIColor colorWithHexString: [randomColors objectAtIndex:gradientInt]];
          if(color == nil){
            color = [UIColor colorWithHexString:@"#2EB82E"];
          }
          FilterModel *model = [[FilterModel alloc]initWithBarColor:color filterTitle:funnlName newMessageCount:0 dateOfLastMessage:[NSDate new] sendersArray:(NSMutableArray*)[dictionaryOfConversations allValues] subjectsArray:(NSMutableArray*)[dictionaryOfSubjects allValues]];
          [EmailService setNewFilterModel:model];
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
