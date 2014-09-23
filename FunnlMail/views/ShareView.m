//
//  ShareView.m
//  FunnlMail
//
//  Created by Macbook on 7/17/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ShareView.h"
#import "MainView.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "MainFilterCell.h"
//#import "FilterModel.h"
#import "FunnelModel.h"
//newly added by iauro001 on 10th June 2014
#import "FunnelService.h"
#import "EmailService.h"
#import "UIColor+HexString.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "TITokenField.h"
#import <AddressBook/AddressBook.h>
#import "ContactService.h"
#import <Mixpanel/Mixpanel.h>


@implementation ShareView

- (id)initWithFrame:(CGRect)frame withFunnlModel:(FunnelModel*)fm
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.97];
        self.imapSession = [EmailService instance].imapSession;
        funnelModel = fm;
        [self setupView];
    }
    return self;
}


#pragma mark - createFieldViewWithFrame functions

-(TITokenFieldView*)createFieldViewWithFrame:(CGRect)frame{
    NSLog(@"what is frame: %f",frame.origin.y);
    TITokenFieldView *tokenFieldView = [[TITokenFieldView alloc] initWithFrame:frame];
    //	[tokenFieldView setSourceArray:[Names listOfNames]];
	[tokenFieldView.tokenField setDelegate:self];
	[tokenFieldView setShouldSearchInBackground:NO];
	[tokenFieldView setShouldSortResults:NO];
	[tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:TITokenFieldControlEventFrameDidChange];
	[tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",; ;"]]; // Default is a comma
    
    
    //	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    //	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
    //	[tokenFieldView.tokenField setRightView:addButton];
	[tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
	[tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
    return tokenFieldView;
}

#pragma mark - setupView / viewDidLoad

-(void)setupView{
    
    UILabel *funnelLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 70, 320-50, 30)];
    funnelLabel.text = [NSString stringWithFormat:@"Share Funnl '%@' With",funnelModel.filterTitle];
    funnelLabel.numberOfLines = 1;
    [funnelLabel setTextAlignment:NSTextAlignmentLeft];
    [funnelLabel setFont:[UIFont boldSystemFontOfSize:20]];
    funnelLabel.textColor = WHITE_CLR;
    [self addSubview:funnelLabel];
    funnelLabel.backgroundColor = CLEAR_COLOR;
    
    UILabel *staticLabelForRecipient = [[UILabel alloc] initWithFrame:CGRectMake(8, funnelLabel.frame.origin.y+funnelLabel.frame.size.height, 320-16, 20)];
    staticLabelForRecipient.text = [NSString stringWithFormat:@"(Enter recipient's Email)"];
    staticLabelForRecipient.numberOfLines = 1;
    [staticLabelForRecipient setTextAlignment:NSTextAlignmentLeft];
    [staticLabelForRecipient setFont:[UIFont systemFontOfSize:18]];
    staticLabelForRecipient.textColor = LIGHT_GRAY_COLOR;
    [self addSubview:staticLabelForRecipient];
    staticLabelForRecipient.backgroundColor = CLEAR_COLOR;
    
    
    toFieldView = [self createFieldViewWithFrame:CGRectMake(0, staticLabelForRecipient.frame.origin.y + staticLabelForRecipient.frame.size.height + 5, WIDTH, 41)];
    [self addSubview:toFieldView];
    [toFieldView.tokenField setPromptText:@"To:"];
	[toFieldView.tokenField setPlaceholder:@""];
    toFieldView.delegate = self;
    toFieldView.tokenField.textColor = WHITE_CLR;
    toFieldView.tag = 1;
    toFieldView.backgroundColor=  CLEAR_COLOR;
    toFieldView.tokenField.backgroundColor = CLEAR_COLOR;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 23, 40, 40)];
    [closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [closeButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [closeButton setContentMode:UIViewContentModeCenter];
    UIImage *sampleImage = [UIImage imageNamed:@"close"];
    sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [closeButton setImage:sampleImage forState:UIControlStateNormal];
    closeButton.tintColor = [UIColor whiteColor];
    sampleImage = nil;
    [closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [headerView addSubview:editButton];
    [self addSubview:closeButton];

    
    _messageView = [[UITextView alloc] initWithFrame:CGRectMake(8, 0, WIDTH-16, toFieldView.frame.size.height)];
	[_messageView setScrollEnabled:NO];
    _messageView.editable = NO;
	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
	[_messageView setDelegate:self];
    _messageView.backgroundColor= CLEAR_COLOR;
    _messageView.textColor= LIGHT_GRAY_COLOR;
	[_messageView setFont:[UIFont systemFontOfSize:13]];
	[_messageView setText:@"\n\n\n\n\n\n\nShairing Funnls helps your team members and friends get organized with just one click. None of your personal emails and info is shared."];
	[toFieldView.contentView addSubview:_messageView];

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(20, 60, 320-60, 40);
    [sendButton setBackgroundColor:[UIColor colorWithHexString:@"#1B8EEE"]];
    [sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [sendButton setTitleColor:WHITE_CLR forState:UIControlStateNormal];
    [sendButton setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(shareFunnlClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_messageView addSubview:sendButton];
    
//    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    closeButton.frame = CGRectMake(320-40, 70, 40, 40);
//    [closeButton setBackgroundColor:[UIColor colorWithHexString:@"#1B8EEE"]];
//    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
//    [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
//    [closeButton setTitleColor:WHITE_CLR forState:UIControlStateNormal];
//    [closeButton setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateHighlighted];
//    [closeButton setImage:[UIImage imageNamed:@"MPCloseBtn"] forState:UIControlStateNormal];
//    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:closeButton];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleFingerTap.delegate = self;
    singleFingerTap.cancelsTouchesInView = NO;
    singleFingerTap.delaysTouchesEnded = NO;
//    [self addGestureRecognizer:singleFingerTap];
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 121, self.bounds.size.width, 180)];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [autocompleteTableView setTableFooterView:footerView];
    footerView = nil;
    [self addSubview:autocompleteTableView];
    
    [self emailContact];

}

-(void)closeButtonClicked:(id)sender{
    [toFieldView.tokenField resignFirstResponder];
    [self setHidden:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [toFieldView.tokenField resignFirstResponder];
    [self setHidden:YES];
}

#pragma mark - shareFunnlClicked functions
-(void)shareFunnlClicked:(id)sender{
    
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Shared a Funnl (pressed send button successfully after entering email)"];
#endif
    
    [toFieldView.tokenField resignFirstResponder];
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:self.imapSession.username]];
    NSMutableArray *toArray = [[NSMutableArray alloc] init];
//    MCOAddress *newAddress = [MCOAddress addressWithMailbox:@"iaurosys@gmail.com"];
    MCOAddress *newAddress = [MCOAddress addressWithMailbox:[toFieldView.tokenTitles componentsJoinedByString:@","]];
    [toArray addObject:newAddress];
    
    NSMutableArray *ccArray = [[NSMutableArray alloc] init];
    newAddress = [MCOAddress addressWithMailbox:[toFieldView.tokenTitles componentsJoinedByString:@","]];
    [ccArray addObject:newAddress];
    [[builder header] setCc:ccArray];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:funnelModel.filterTitle,funnelModel.sendersArray,funnelModel.subjectsArray,nil] forKeys:[NSArray arrayWithObjects:@"name",@"senders",@"subjects", nil]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (! jsonData) {
        jsonString = @"";
        NSLog(@"Got an error: %@", error);
    }
    else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    //     NSLog(@"%@",jsonString);
    NSString *base64EncodedString = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

    NSString *subjectString = [NSString stringWithFormat:@"Stay on top of %@ emails with FunnlMail.",funnelModel.filterTitle];
    [[builder header] setSubject:subjectString];
    
    //    NSString *funnlLinkStr = [NSString stringWithFormat:@"<a href=funnl://name=%@&from=%@&subject=%@> Get Funnl </a>",fm.filterTitle,[fm.sendersArray componentsJoinedByString:@","],[fm.subjectsArray componentsJoinedByString:@","]];
    NSString *funnlLinkStr = [NSString stringWithFormat:@"<a href=funnl://%@> View & import Funnl   </a>",base64EncodedString];
    NSString *htmlString = [[NSString alloc] initWithFormat:
                            @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\
                            <html>\
                            <head>\
                            <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\
                            <meta http-equiv=\"Content-Style-Type\" content=\"text/css\">\
                            <title></title>\
                            <meta name=\"Generator\" content=\"Cocoa HTML Writer\">\
                            <style type=\"text/css\">\
                            p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px '.Helvetica Neue Interface'}\
                            span.s1 {font-family: '.HelveticaNeueInterface-Regular'; font-weight: normal; font-style: normal; font-size: 12.00pt}\
                            </style>\
                            </head>\
                            <body>\
                            <p class=\"p1\"><span class=\"s1\">\
                            <a href=\"http://bit.do/funnlmailsite\">FunnlMail</a>\
                            for iOS helps me stay on top of important emails on-the-go!<br/><br/>\
                            I am sharing my custom Funnl for %@ with you - with just one tap below, you can get my filter settings and custom alerts for %@, so that you dont miss these important emails among the clutter in your inbox.<br/><br/>\
                            You can also edit/ delete these settings anytime later if you dont need them anymore.<br/><br/>\
                            %@<br/>\
                            (works only within FunnlMail iOS app)\
                            <br/><br/>\
                            Or, if you don't have FunnlMail, \
                            <a href=\"http://bit.do/funnlmailsite\">Download the FunnlMail iOS app</a>\
                            <br/>\
                            (Limited Alpha Release)\
                            </span></p>\
                            </body></html>",funnelModel.funnelName,funnelModel.funnelName, funnlLinkStr];
    [builder setHTMLBody:htmlString];
    rfc822Data = [builder data];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    MCOSMTPSendOperation *sendOperation = [[EmailService instance].smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Error sending email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            //            [alert show];
            NSLog(@"%@ Error sending email:%@", [EmailService instance].smtpSession.username, error);
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
        }
        else
        {
            self.hidden = YES;
            NSLog(@"%@ Successfully sent email!", [EmailService instance].smtpSession.username);
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
            [[[EmailService instance].imapSession appendMessageOperationWithFolder:SENT messageData:rfc822Data flags:MCOMessageFlagMDNSent] start:^(NSError *error, uint32_t createdUID) {
                if (error)
                    NSLog(@"error adding message to sent folder");
                else
                    NSLog(@"successfully appended message to sent folder");
            }];
        }
    }];
}

#pragma mark - keyboard functions

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
    int tabBarOffset = 40;
	[toFieldView setFrame:((CGRect){toFieldView.frame.origin, {self.bounds.size.width, self.bounds.size.height + tabBarOffset - _keyboardHeight}})];
//	[_messageView setFrame:toFieldView.contentView.bounds];
    [_messageView setFrame:CGRectMake(8, 0, WIDTH-16, toFieldView.frame.size.height)];
    
}

#pragma mark - TITokenField delegate

- (BOOL)tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token;{
    return YES;
}

- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
    [self resizeViews];
    return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField
{
    NSLog(@"%@ - %@",[tokenField description], NSStringFromCGRect(tokenField.frame));
    //	[self textViewDidChange:messageView];
    [self resizeViews];
}


- (void)tokenField:(TITokenField *)field performCustomSearchForSearchString:(NSString *)searchString withCompletionHandler:(void (^)(NSArray *))completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Send a Github API request to retrieve the Contributors of this project.
        //Using a syncrhonous request in a Background Thread to not over-complexify the demo project
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/repos/thermogl/TITokenField/contributors"]];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        if (error == nil) {
            NSError *errorJSON;
            NSArray *contributors = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
            
            for (NSDictionary *user in contributors) {
                [results addObject:[user objectForKey:@"login"]];
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //Finally call the completionHandler with the results array!
            completionHandler(results);
        });
    });
}

#pragma mark - TextView delegate

- (void)textViewDidChange:(UITextView *)textView {
	
    CGFloat oldHeight = toFieldView.frame.size.height - toFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = toFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < oldHeight){
		newTextFrame.size.height = oldHeight;
		newFrame.size.height = oldHeight;
	}
    
	[toFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[toFieldView updateContentSize];

	
}

#pragma this is what initiates autocomplete
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSLog(@"is thi shappengin");
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring
                 stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    NSLog(@"what is count: %lu",(unsigned long)searchArray.count);
    if(searchArray.count != 0){
        CGFloat temp = toFieldView.tokenField.frame.size.height+121;
        autocompleteTableView.frame = CGRectMake(autocompleteTableView.frame.origin.x, temp, autocompleteTableView.frame.size.width, autocompleteTableView.frame.size.height);
        autocompleteTableView.scrollEnabled = YES;
        autocompleteTableView.hidden = NO;
        //[self addSubview:autocompleteTableView];
    }
    else
        autocompleteTableView.hidden = YES;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"did press enter");
    autocompleteTableView.hidden = YES;
    //    else if (bccFieldView.tokenField.isEditing)[self.view setFrame:CGRectMake(0,75,self.view.bounds.size.width,self.view.bounds.size.height)];
    return YES;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the searchArray
    // The items in this array is what will show up in the table view
    [searchArray removeAllObjects];
    if(substring.length){
//        emailArr = [[NSMutableArray alloc] initWithArray:[[ContactService instance] searchContactsWithString:substring]];
//        for(NSMutableString *curString in emailArr) {
//            
//            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            
//            if ([curString rangeOfString:substring].location == 0) {
//                [searchArray addObject:curString];
//            }
//            
//        }
        emailArr = [[NSMutableArray alloc] initWithArray:[[ContactService instance] searchContactModelWithString:substring]];
        for(ContactModel *tempModel in emailArr) {
            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([tempModel.email rangeOfString:substring].location == 0) {
                [searchArray addObject:tempModel];
            }
        }
    }
    if(searchArray.count <= 0){
        autocompleteTableView.hidden = YES;
    }
    else{
        autocompleteTableView.hidden = NO;
//        dispatch_async(dispatch_get_main_queue(), ^{
            [autocompleteTableView reloadData];
//        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelctRow");
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if(toFieldView.tokenField.isEditing){
        NSLog(@"to is editing");
//        if ([selectedCell.textLabel.text isEqualToString:@"Recent"]) {
//            toFieldView.tokenField.text = selectedCell.detailTextLabel.text;
//        }
//        else
//            toFieldView.tokenField.text = selectedCell.textLabel.text;
        toFieldView.tokenField.text = selectedCell.detailTextLabel.text;
        //[autocompleteTableView removeFromSuperview];
    }
    autocompleteTableView.hidden = YES;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
//    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    if(indexPath.row <= searchArray.count){
        if ([(ContactModel *)[searchArray objectAtIndex:indexPath.row] name]) {
            if ([[(ContactModel *)[searchArray objectAtIndex:indexPath.row] name] length]) {
                cell.textLabel.text = [(ContactModel *)[searchArray objectAtIndex:indexPath.row] name];
                [cell.textLabel setTextColor:[UIColor blackColor]];
            }
            else {
                cell.textLabel.text = @"Recent";
                [cell.textLabel setTextColor:[UIColor grayColor]];
            }
        }
        else {
            cell.textLabel.text = @"Recent";
        }
        cell.detailTextLabel.text = [(ContactModel *)[searchArray objectAtIndex:indexPath.row] email];
    }
    return cell;
}

#pragma mark loadContacts
//this will need to put somewhere so it happens only once
//it will take longer to do the more contacts there are obviously
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



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
