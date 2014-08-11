
//
//  ComposeViewController.m
//  FunnlMail
//
//  Created by Macbook on 7/14/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ComposeViewController.h"
#import "TITokenField.h"
#import "Names.h"
#include <MailCore/MailCore.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "EmailService.h"
#import "MBProgressHUD.h"
#import <Mixpanel/Mixpanel.h>
#import <AddressBook/AddressBook.h>
#import <CoreText/CoreText.h>
#import "ContactService.h"
#import "ContactModel.h"

static NSString * mainJavascript = @"\
var imageElements = function() {\
var imageNodes = document.getElementsByTagName('img');\
return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
var images = imageElements();\
\
var imgLinks = [];\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
imgLinks.push(url);\
}\
return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
var images = imageElements();\
\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf(info.URLKey) == 0) {\
images[i].setAttribute('src', info.LocalPathKey);\
break;\
}\
}\
};\
";

static NSString * mainStyle = @"\
body {\
font-family: Helvetica;\
font-size: 14px;\
word-wrap: break-word;\
-webkit-text-size-adjust:none;\
-webkit-nbsp-mode: space;\
}\
\
pre {\
white-space: pre-wrap;\
}\
";
NSData * rfc822Data;
NSString *msgBody;
NSMutableArray *emailArr,*searchArray;


@interface ComposeViewController ()

@end


@interface ComposeViewController (Private)
- (void)resizeViews;
@end

@implementation ComposeViewController {
	TITokenFieldView * toFieldView, *ccFieldView, *bccFieldView, *subjectFieldView;
	UITextView * messageView;
	UITableView *autocompleteTableView;
	CGFloat _keyboardHeight;
}



#pragma this is what initiates autocomplete
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if([@"Subject:"  isEqual: ((UILabel *)(TITokenField *)textField.leftView).text]){
        return YES;
    }
    if([@"To:"  isEqual: ((UILabel *)(TITokenField *)textField.leftView).text]){
        autocompleteTableView.hidden = NO;
        //[self.view addSubview:autocompleteTableView];
        
    }
    else if ([@"Cc:"  isEqual: ((UILabel *)(TITokenField *)textField.leftView).text]){
        NSLog(@"cc did start");
        autocompleteTableView.hidden = NO;
        //[self.view setFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
        //autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, self.view.bounds.size.width, 120)];
        //[self.view addSubview:autocompleteTableView];

    }
   else if ([@"Bcc:"  isEqual: ((UILabel *)(TITokenField *)textField.leftView).text]){
       NSLog(@"Bcc did start");
       autocompleteTableView.hidden = NO;
       //[self.view setFrame:CGRectMake(0,-30,self.view.bounds.size.width,self.view.bounds.size.height)];
       //autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, 120)];
       //[self.view addSubview:autocompleteTableView];
    }
    
    if(string.length == 0){
        autocompleteTableView.hidden = YES;
//        if ([@"Cc:"  isEqual: ((UILabel *)(TITokenField *)textField.leftView).text]){
//            [self.view setFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
//        }
    }
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    if(searchArray.count != 0) autocompleteTableView.hidden = NO;
    else autocompleteTableView.hidden = YES;
    return YES;
}

//this is the reason it fails when reselecting the tokenFields
//pranav replace this with textField
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
//    NSLog(@"does it know it is over");
//    NSLog(@"cc is this true?: %hhd",[@"Cc:"  isEqual: ((UILabel *)((TITokenField *)textView).leftView).text]);
//    NSLog(@"bcc is this true?: %hhd",[@"Cc:"  isEqual: ((UILabel *)((TITokenField *)textView).leftView).text]);
//    autocompleteTableView.hidden = YES;
//    if(ccFieldView.tokenField.isEditing)[self.view setFrame:CGRectMake(0,25,self.view.bounds.size.width,self.view.bounds.size.height)];
//    else if (bccFieldView.tokenField.isEditing)[self.view setFrame:CGRectMake(0,50,self.view.bounds.size.width,self.view.bounds.size.height)];
//    
//    return YES;
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"did press enter");
    autocompleteTableView.hidden = YES;
    if(ccFieldView.tokenField.isEditing){
        NSLog(@"ccFieldView isEditing");
        //[self.view setFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height+10)];
    }
//    else if (bccFieldView.tokenField.isEditing)[self.view setFrame:CGRectMake(0,75,self.view.bounds.size.width,self.view.bounds.size.height)];
    return YES;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
        else{
            [searchArray removeAllObjects];
        }

//        dispatch_async(dispatch_get_main_queue(), ^{
            [autocompleteTableView reloadData];
//        });
    //});
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelctRow");
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if(toFieldView.tokenField.isEditing){
        NSLog(@"to is editing");
        toFieldView.tokenField.text = selectedCell.textLabel.text;
        //[autocompleteTableView removeFromSuperview];
    }
    else if(ccFieldView.tokenField.isEditing){
        NSLog(@"cc is editing");
        ccFieldView.tokenField.text = selectedCell.textLabel.text;
        //[self.view setFrame:CGRectMake(0,25,self.view.bounds.size.width,self.view.bounds.size.height)];
        //[autocompleteTableView removeFromSuperview];
    }
    else{
        NSLog(@"bcc is editing");
        bccFieldView.tokenField.text = selectedCell.textLabel.text;
        //[self.view setFrame:CGRectMake(0,50,self.view.bounds.size.width,self.view.bounds.size.height)];
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
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    cell.textLabel.text = [searchArray objectAtIndex:indexPath.row];
    return cell;
}


-(void)cancelButtonSelected{
    [[Mixpanel sharedInstance] track:@"Cancel button from composeVC"];
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendButtonSelected{
//    NSLog(@"%@, %@, ",toFieldView.tokenTitles, toFieldView.tokenField.text, toFieldView);
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:self.imapSession.username]];
    NSMutableArray *toArray = [[NSMutableArray alloc] init];
    MCOAddress *newAddress = [MCOAddress addressWithMailbox:[toFieldView.tokenTitles componentsJoinedByString:@","]];
    [toArray addObject:newAddress];
    [[builder header] setTo:toArray];
    NSMutableArray *ccArray = [[NSMutableArray alloc] init];
    newAddress = [MCOAddress addressWithMailbox:[ccFieldView.tokenTitles componentsJoinedByString:@","]];
    [ccArray addObject:newAddress];
    [[builder header] setCc:ccArray];
    NSMutableArray *bccArray = [[NSMutableArray alloc] init];
    newAddress = [MCOAddress addressWithMailbox:[bccFieldView.tokenTitles componentsJoinedByString:@","]];
    [bccArray addObject:newAddress];
    [[builder header] setBcc:bccArray];
    [[builder header] setSubject:subjectFieldView.tokenField.text];
    
    NSAttributedString *attrString = messageView.attributedText;
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSData *htmlData = [attrString dataFromRange:NSMakeRange(0, [attrString length]) documentAttributes:options error:nil];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    [builder setHTMLBody:htmlString];
    rfc822Data = [builder data];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MCOSMTPSendOperation *sendOperation = [[EmailService instance].smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Error sending email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            NSLog(@"%@ Error sending email:%@", [EmailService instance].smtpSession.username, error);
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            NSLog(@"%@ Successfully sent email!", [EmailService instance].smtpSession.username);
            [[Mixpanel sharedInstance] track:@"Send Button from composeVC"];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //[self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
            [[[EmailService instance].imapSession appendMessageOperationWithFolder:SENT messageData:rfc822Data flags:MCOMessageFlagMDNSent] start:^(NSError *error, uint32_t createdUID) {
                if (error)
                    NSLog(@"error adding message to sent folder");
                else NSLog(@"successfully appended message to sent folder");
            }];
        }
    }];
    
}





-(TITokenFieldView*)createFieldViewWithFrame:(CGRect)frame{
    TITokenFieldView *tokenFieldView = [[TITokenFieldView alloc] initWithFrame:frame];
//	[tokenFieldView setSourceArray:[Names listOfNames]];
	[tokenFieldView.tokenField setDelegate:self];
	[tokenFieldView setShouldSearchInBackground:NO];
	[tokenFieldView setShouldSortResults:NO];
	[tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:TITokenFieldControlEventFrameDidChange];
	[tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;"]]; // Default is a comma
  		
//	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
//	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
//	[tokenFieldView.tokenField setRightView:addButton];
	[tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
	[tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
    return tokenFieldView;
}

- (void)viewDidLoad {
    
    [self emailContact];
    
     previousRect = CGRectMake(0, 0, 0, 0);
    self.imapSession = [EmailService instance].imapSession;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Mail";

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonSelected)];
    self.navigationItem.leftBarButtonItem = leftItem;

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonSelected)];
    self.navigationItem.rightBarButtonItem = rightItem;

    
    toFieldView = [self createFieldViewWithFrame:CGRectMake(0, 0, WIDTH, 41)];
    [self.view addSubview:toFieldView];
    [toFieldView.tokenField setPromptText:@"To:"];
	[toFieldView.tokenField setPlaceholder:@""];
    
    toFieldView.delegate = self;
    toFieldView.tag = 1;
    
    ccFieldView = [self createFieldViewWithFrame:CGRectMake(0, 0, WIDTH, 41)];
    [ccFieldView.tokenField setPromptText:@"Cc:"];
	[ccFieldView.tokenField setPlaceholder:@""];
    [toFieldView.contentView addSubview:ccFieldView];
    ccFieldView.scrollEnabled = NO;
    ccFieldView.tag = 2;
    
    bccFieldView = [self createFieldViewWithFrame:CGRectMake(0, 0, WIDTH, 41)];
    [bccFieldView.tokenField setPromptText:@"Bcc:"];
	[bccFieldView.tokenField setPlaceholder:@""];
    [toFieldView.contentView addSubview:bccFieldView];
    bccFieldView.scrollEnabled = NO;
    bccFieldView.tag = 3;
    
    subjectFieldView = [self createFieldViewWithFrame:CGRectMake(0, 0, WIDTH, 0)];
    [subjectFieldView.tokenField setPromptText:@"Subject:"];
	[subjectFieldView.tokenField setPlaceholder:@""];
    [toFieldView.contentView addSubview:subjectFieldView];
    subjectFieldView.tokenField.hideBubble = YES;
    subjectFieldView.scrollEnabled = NO;

	messageView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 208)];
	[messageView setScrollEnabled:NO];
	[messageView setAutoresizingMask:UIViewAutoresizingNone];
	[messageView setDelegate:self];
	[messageView setFont:[UIFont systemFontOfSize:15]];
	[messageView setText:@""];
//    messageView.backgroundColor = [UIColor colorWithHexString:@"#"];
	[toFieldView.contentView addSubview:messageView];
	
    if (self.forward) {
        NSLog(@"self.forward");
        NSMutableString *temp = [[NSMutableString alloc] initWithString:@"FWD: "];
        [temp appendString:self.message.header.subject];
        subjectFieldView.tokenField.text = temp;
    }
    else if (self.reply){
        NSLog(@"self.reply");
        NSMutableString *temp = [[NSMutableString alloc] initWithString:@"Re: "];
        [temp appendString:self.message.header.subject];
        subjectFieldView.tokenField.text = temp;
        toFieldView.tokenField.text = [self.address nonEncodedRFC822String];
    }
    else if(self.replyAll){
        NSLog(@"self.reply");
        NSMutableString *temp = [[NSMutableString alloc] initWithString:@"Re: "];
        [temp appendString:self.message.header.subject];
        subjectFieldView.tokenField.text = temp;
        
        temp = [[NSMutableString alloc] initWithString:[self.address nonEncodedRFC822String]];
        
        for (MCOAddress* address in self.addressArray) {
            [temp appendString:@", "];
            [temp appendString:[address nonEncodedRFC822String]];
            
        }
        
        toFieldView.tokenField.text = temp;
    }

    if (!self.compose) {
        NSString *htmlString = [self getBodyData];
        htmlString = [ htmlString stringByReplacingOccurrencesOfString:@"<body bgColor=\"transparent;\">" withString:@"<body bgColor=\"transparent;\"><br/><br/>"];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

        NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        [finalAttributedString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                          range:(NSRange){0,[finalAttributedString length]}];
        
        [finalAttributedString appendAttributedString:attributedString];
        messageView.attributedText = finalAttributedString;
//        [self applyPlainBodyString];
        if(messageView.text.length){
            CGRect frame = [finalAttributedString boundingRectWithSize:CGSizeMake(WIDTH, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics context:nil];
            NSLog(@"%@",NSStringFromCGRect(frame));
            messageView.frame = CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y, WIDTH, MAX(208, frame.size.height));
//            [self textViewDidChange:messageView];
//            [self resizeViews];
        }
        
//Uncomment below line for the plain body reply/replyAll/forward body
//        [self applyPlainBodyString
    }
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 121, self.view.bounds.size.width, 180)];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;

    [self.view addSubview:autocompleteTableView];
    
    [toFieldView.tokenField tokenizeText];
    
    if(toFieldView.tokenTitles.count){
    	[toFieldView.tokenField setPlaceholder:@""];
    }
    if(ccFieldView.tokenTitles.count){
    	[ccFieldView.tokenField setPlaceholder:@""];
    }
    if(bccFieldView.tokenTitles.count){
    	[bccFieldView.tokenField setPlaceholder:@""];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// You can call this on either the view on the field.
	// They both do the same thing.
    [toFieldView becomeFirstResponder];
}


-(void)applyPlainBodyString{
    
    MCOIMAPFetchContentOperation *operation = [self.imapSession fetchMessageByUIDOperationWithFolder:INBOX uid:self.message.uid];
    
    [operation start:^(NSError *error, NSData *data) {
        MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
        msgBody = [messageParser plainTextRendering];
        NSMutableString *temp = [[NSMutableString alloc] initWithString:@"\n\n______________________________________\n"];
        [temp appendString:msgBody];
        messageView.text = temp;
        temp = nil;
    }];
    NSLog(@"message is not empty");
}


-(NSString*)getBodyData
{
    NSString *uidKey = [NSString stringWithFormat:@"%d", self.message.uid];
    NSString *string = [[MessageService instance] retrieveHTMLContentWithID:uidKey];
    NSString * content = @"";
    if (string == nil || string.length == 0 )
        string = @"";
    
    if (![string isEqualToString:EMPTY_DELIMITER] && string && ![string isEqualToString:@""]) {
        NSMutableString * html = [NSMutableString string];
                [html appendFormat:@"<html><br><br><br><font color='purple'><head>------------------------------------------------------------------<script>%@</script><style>%@</style></head>"
         @"<body bgColor=\"transparent;\">%@</body></font></html>", mainJavascript, mainStyle, string];
        return html;
    }
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    if ([_message isKindOfClass:[MCOIMAPMessage class]]) {
        content = [(MCOIMAPMessage *) self.message htmlRenderingWithFolder:INBOX delegate:self];
        if (content) {
            NSArray *tempArray = [content componentsSeparatedByString:@"<head>"];
            if (tempArray.count > 1) {
                content = [tempArray objectAtIndex:1];
            }
            else {
                tempArray = [content componentsSeparatedByString:@"Subject:"];
                if (tempArray.count > 1) {
                    content = [tempArray objectAtIndex:1];
                }
            }
            paramDict[uidKey] = content;
            [[MessageService instance] updateMessageWithHTMLContent:paramDict];
            NSMutableString * html = [NSMutableString string];
            [html appendFormat:@"<html><head><script>%@</script><style>%@</style></head>"
             @"<body bgColor=\"transparent;\">%@</body></html>", mainJavascript, mainStyle, content];

            return html;
        }
        else
            return @"";
    }
    return @"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self resizeViews];}]; // Make it pweeetty.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeViews];
}



- (void)showContactsPicker:(id)sender {
	
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
	
	NSArray * names = [Names listOfNames];
	
	TIToken * token = [toFieldView.tokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
	// If the size of the token might change, it's a good idea to layout again.
	[toFieldView.tokenField layoutTokensAnimated:YES];
	
	NSUInteger tokenCount = toFieldView.tokenField.tokens.count;
	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    NSLog(@"what is the keyboard height: %f",_keyboardHeight);
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
	[toFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, toFieldView.frame.origin.y, WIDTH, HEIGHT - _keyboardHeight - 64)];
	[ccFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, 0, WIDTH, ccFieldView.tokenField.frame.size.height+2)];
	[bccFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, ccFieldView.frame.origin.y + ccFieldView.frame.size.height, WIDTH, bccFieldView.tokenField.frame.size.height+2)];
	[subjectFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, ccFieldView.frame.size.height + bccFieldView.frame.size.height, WIDTH, 40)];
	[messageView setFrame:CGRectMake(toFieldView.frame.origin.x,  ccFieldView.frame.size.height + bccFieldView.frame.size.height + subjectFieldView.frame.size.height, WIDTH, messageView.frame.size.height)];
    [self textViewDidChange:messageView];
}

- (BOOL)tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token;{
    if(tokenField == subjectFieldView.tokenField){
        return YES;
    }
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
   // NSLog(@"%@ - %@",[tokenField description], NSStringFromCGRect(tokenField.frame));
//	[self textViewDidChange:messageView];
    [self resizeViews];
}

- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat oldHeight = toFieldView.frame.size.height - toFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = toFieldView.contentView.frame ;
	newFrame.size.height = newHeight   ;
	
	if (newHeight < oldHeight){
		newTextFrame.size.height = oldHeight;
		newFrame.size.height = oldHeight;
	}

    UITextPosition* pos = textView.endOfDocument;//explore others like beginningOfDocument if you want to customize the behaviour
    CGRect currentRect = [textView caretRectForPosition:pos];
    
    if (currentRect.origin.y > previousRect.origin.y && (textView.contentSize.height + textView.font.lineHeight) > 208){
        //new line reached, write your code
        textView.frame = CGRectMake(textView.frame.origin.x,  ccFieldView.frame.size.height + bccFieldView.frame.size.height + subjectFieldView.frame.size.height, WIDTH, textView.frame.size.height + textView.font.lineHeight);
    }else{
//        textView.frame = CGRectMake(textView.frame.origin.x, 44, WIDTH, textView.contentSize.height );
    }
    [toFieldView.contentView setFrame:newFrame];
    previousRect = currentRect;

	[toFieldView updateContentSize];
	[ccFieldView updateContentSize];
	[bccFieldView updateContentSize];
	[subjectFieldView updateContentSize];

    [messageView setNeedsDisplay];
    [messageView setNeedsLayout];
    [self.view bringSubviewToFront:messageView];
    //NSLog(@" %@ - %@ - %@ - %@",NSStringFromCGSize(toFieldView.contentView.frame.size),NSStringFromCGRect(ccFieldView.frame),NSStringFromCGRect(subjectFieldView.frame),NSStringFromCGRect(messageView.frame));
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


@end
