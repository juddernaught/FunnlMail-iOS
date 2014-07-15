
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


@interface ComposeViewController ()

@end


@interface ComposeViewController (Private)
- (void)resizeViews;
@end

@implementation ComposeViewController {
	TITokenFieldView * toFieldView, *ccFieldView, *bccFieldView, *subjectFieldView;
	UITextView * messageView;
	
	CGFloat _keyboardHeight;
}


-(void)cancelButtonSelected{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    [builder setHTMLBody:messageView.text];
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
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:NULL];
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
    
    ccFieldView = [self createFieldViewWithFrame:CGRectMake(0, 0, WIDTH, 41)];
    [ccFieldView.tokenField setPromptText:@"Cc:"];
	[ccFieldView.tokenField setPlaceholder:@""];
    [toFieldView.contentView addSubview:ccFieldView];
    ccFieldView.scrollEnabled = NO;
    
    bccFieldView = [self createFieldViewWithFrame:CGRectMake(0, 0, WIDTH, 41)];
    [bccFieldView.tokenField setPromptText:@"Bcc:"];
	[bccFieldView.tokenField setPlaceholder:@""];
    [toFieldView.contentView addSubview:bccFieldView];
    bccFieldView.scrollEnabled = NO;
    
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
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        messageView.attributedText = attributedString;
        
        if(messageView.text.length){
            CGRect frame = [attributedString boundingRectWithSize:CGSizeMake(WIDTH, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics context:nil];
            NSLog(@"%@",NSStringFromCGRect(frame));
            messageView.frame = CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y, WIDTH, frame.size.height);
//            [self textViewDidChange:messageView];
//            [self resizeViews];
        }
        
//Uncomment below line for the plain body reply/replyAll/forward body
//        [self applyPlainBodyString];
    }
    
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
    
    MCOIMAPFetchContentOperation *operation = [self.imapSession fetchMessageByUIDOperationWithFolder:@"INBOX" uid:self.message.uid];
    
    [operation start:^(NSError *error, NSData *data) {
        MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
        msgBody = [messageParser plainTextRendering];
        NSMutableString *temp = [[NSMutableString alloc] initWithString:@"____________________________________________________"];
        [temp appendString:msgBody];
        messageView.text = temp;
        temp = nil;
    }];
    NSLog(@"message is empty");
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
        [html appendFormat:@"<html><head><script>%@</script><style>%@</style></head>"
         @"<body bgColor=\"transparent;\">%@</body></html>", mainJavascript, mainStyle, string];
        return html;
    }
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    if ([_message isKindOfClass:[MCOIMAPMessage class]]) {
        content = [(MCOIMAPMessage *) self.message htmlRenderingWithFolder:@"INBOX" delegate:self];
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
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
//	[toFieldView setFrame:((CGRect){toFieldView.frame.origin, {WIDTH, HEIGHT  - _keyboardHeight}})];
//	[ccFieldView setFrame:((CGRect){toFieldView.frame.origin, {WIDTH, HEIGHT  - _keyboardHeight}})];
//	[bccFieldView setFrame:((CGRect){ccFieldView.frame.origin, {WIDTH, HEIGHT - _keyboardHeight}})];
//	[subjectFieldView setFrame:((CGRect){bccFieldView.frame.origin, {WIDTH, HEIGHT - _keyboardHeight}})];
//	[messageView setFrame:((CGRect){subjectFieldView.frame.origin, {WIDTH, HEIGHT - _keyboardHeight}})];

	[toFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, toFieldView.frame.origin.y, WIDTH, HEIGHT - _keyboardHeight - 64)];
	[ccFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, 0, WIDTH, ccFieldView.tokenField.frame.size.height+1)];
	[bccFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, ccFieldView.tokenField.frame.origin.y + ccFieldView.tokenField.frame.size.height, WIDTH, bccFieldView.tokenField.frame.size.height)];
	[subjectFieldView setFrame:CGRectMake(toFieldView.frame.origin.x, ccFieldView.tokenField.frame.size.height + bccFieldView.tokenField.frame.size.height, WIDTH, 40)];
	[messageView setFrame:CGRectMake(toFieldView.frame.origin.x,  ccFieldView.tokenField.frame.size.height + bccFieldView.tokenField.frame.size.height + subjectFieldView.frame.size.height, messageView.frame.size.width, messageView.frame.size.height)];

    [ self.view bringSubviewToFront:ccFieldView.separator];
    [ccFieldView.separator setFrame:CGRectMake(0, 0, WIDTH, ccFieldView.tokenField.frame.size.height+1)];
    
    [self textViewDidChange:messageView];

    [ccFieldView.separator setFrame:CGRectMake(toFieldView.frame.origin.x, 0, WIDTH, ccFieldView.tokenField.frame.size.height+1)];

//    CGRect newFrame = 
//    [toFieldView.contentView setFrame:newFrame];

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
    NSLog(@"%@ - %@",[tokenField description], NSStringFromCGRect(tokenField.frame));
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
        textView.frame = CGRectMake(textView.frame.origin.x,  ccFieldView.frame.size.height + bccFieldView.frame.size.height + subjectFieldView.frame.size.height, textView.frame.size.width, textView.frame.size.height + textView.font.lineHeight);
    }else{
//        textView.frame = CGRectMake(textView.frame.origin.x, 44, WIDTH, textView.contentSize.height );
    }
    [toFieldView.contentView setFrame:newFrame];
    previousRect = currentRect;
    
    
//	[ccFieldView.contentView setFrame:CGRectMake(toFieldView.frame.origin.x,toFieldView.frame.origin.y, WIDTH, newFrame.size.height)];
//	[bccFieldView.contentView setFrame:CGRectMake(ccFieldView.frame.origin.x,ccFieldView.frame.origin.y, WIDTH, newFrame.size.height)];
//	[subjectFieldView.contentView setFrame:CGRectMake(bccFieldView.frame.origin.x,bccFieldView.frame.origin.y, WIDTH, newFrame.size.height)];
//	[messageView setFrame:CGRectMake(messageView.frame.origin.x,messageView.frame.origin.y, WIDTH, newFrame.size.height)];
//	[textView setFrame:newTextFrame];
	[toFieldView updateContentSize];
	[ccFieldView updateContentSize];
	[bccFieldView updateContentSize];
	[subjectFieldView updateContentSize];

//    [toFieldView setContentSize:CGSizeMake(WIDTH, 400)];
//    [ccFieldView setContentSize:CGSizeMake(WIDTH, 400)];
//    [bccFieldView setContentSize:CGSizeMake(WIDTH, 400)];
//    [subjectFieldView setContentSize:CGSizeMake(WIDTH, 400)];
//    [messageView setContentSize:CGSizeMake(WIDTH, 400)];

    [messageView setNeedsDisplay];
    [messageView setNeedsLayout];
    [self.view bringSubviewToFront:messageView];
    NSLog(@" %@ - %@ - %@ - %@",NSStringFromCGSize(toFieldView.contentView.frame.size),NSStringFromCGRect(ccFieldView.frame),NSStringFromCGRect(subjectFieldView.frame),NSStringFromCGRect(messageView.frame));

    subjectFieldView.backgroundColor = [UIColor clearColor];
//    subjectFieldView.contentSize  = CGSizeMake(WIDTH, 1600);
    
}

/*
#pragma mark - Custom Search

- (BOOL)tokenField:(TITokenField *)field shouldUseCustomSearchForSearchString:(NSString *)searchString
{
    return ([searchString isEqualToString:@"contributors"]);
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

*/
@end
