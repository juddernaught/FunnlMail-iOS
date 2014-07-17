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

NSData * rfc822Data;
NSString *msgBody;

@implementation ShareView

- (id)initWithFrame:(CGRect)frame withFunnlModel:(FunnelModel*)fm
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.93];
        funnelModel = fm;
        [self setupView];
    }
    return self;
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


-(void)setupView{
    
    UILabel *funnelLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 65, 320-16, 30)];
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
    toFieldView.tokenField.backgroundColor = CLEAR_COLOR;
    toFieldView.tag = 1;
    toFieldView.backgroundColor= CLEAR_COLOR;
    toFieldView.tokenField.textColor = WHITE_CLR;
    
    
    _messageView = [[UITextView alloc] initWithFrame:toFieldView.contentView.bounds];
	[_messageView setScrollEnabled:NO];
    _messageView.editable = NO;
	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
	[_messageView setDelegate:self];
    _messageView.backgroundColor= CLEAR_COLOR;
    _messageView.textColor= WHITE_CLR;
	[_messageView setFont:[UIFont systemFontOfSize:15]];
	[_messageView setText:@"\n\n\n\nShairing Funnls helps your team members | friends get orginized with just one click. None of your personal emails | info is shared."];
	[toFieldView.contentView addSubview:_messageView];

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(30, 10, 320-60, 40);
    [sendButton setBackgroundColor:[UIColor colorWithHexString:@"#1B8EEE"]];
    [sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [sendButton setTitleColor:WHITE_CLR forState:UIControlStateNormal];
    [_messageView addSubview:sendButton];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleFingerTap.delegate = self;
    singleFingerTap.cancelsTouchesInView = NO;
    singleFingerTap.delaysTouchesEnded = NO;
    [self addGestureRecognizer:singleFingerTap];

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

-(void)shareFunnlClicked:(id)sender{
    [toFieldView.tokenField resignFirstResponder];
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:self.imapSession.username]];
    NSMutableArray *toArray = [[NSMutableArray alloc] init];
    MCOAddress *newAddress = [MCOAddress addressWithMailbox:@"iaurosys@gmail.com"];
    [toArray addObject:newAddress];
    
    NSMutableArray *ccArray = [[NSMutableArray alloc] init];
    newAddress = [MCOAddress addressWithMailbox:@"iaurosys@gmail.com"];
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
    
    
    NSString *subjectString = [NSString stringWithFormat:@"FunnlMail - Makes Email Simpler, '%@' has shared '%@' Funnl with you.",self.imapSession.username,funnelModel.filterTitle];
    [[builder header] setSubject:subjectString];
    
    //    NSString *funnlLinkStr = [NSString stringWithFormat:@"<a href=funnl://name=%@&from=%@&subject=%@> Get Funnl </a>",fm.filterTitle,[fm.sendersArray componentsJoinedByString:@","],[fm.subjectsArray componentsJoinedByString:@","]];
    NSString *funnlLinkStr = [NSString stringWithFormat:@"<a href=funnl://%@> Get Funnl </a>",base64EncodedString];
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
                            Hi,<br/><br/>\
                            I have  been using Funnl Mail (iOS) to organize my inbox and wanted share Funnl '%@' to help you organize. <br/><br/>%@</span></p>\
                            </body></html>",funnelModel.filterTitle,funnlLinkStr];
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
	[_messageView setFrame:toFieldView.contentView.bounds];
    
}

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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
