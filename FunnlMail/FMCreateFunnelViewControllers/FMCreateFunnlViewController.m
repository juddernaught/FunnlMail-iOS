//
//  VIPCreateFunnelViewController.m
//  VIPFunnel
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//
#import "AppDelegate.h"
#import "FMCreateFunnlViewController.h"
#import "ContactService.h"
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import "FXBlurView.h"
@interface FMCreateFunnlViewController ()

@end

@implementation FMCreateFunnlViewController
@synthesize isEditFunnel;
@synthesize oldModel;
@synthesize mainVCdelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSelectedContactArray:(NSMutableArray *)contactArray name:(NSString *)name andSubjects:(NSMutableArray *)subjects {
    self = [super init];
    if (self) {
        // Custom initialization
        emailTempArray = [[NSMutableArray alloc] initWithArray:contactArray];
        subjectArray = [[NSMutableArray alloc] initWithArray:subjects];
        subjectString = name;
    }
    return self;
}


- (id)initWithSelectedContactArray:(NSMutableArray *)contactArray {
    self = [super init];
    if (self) {
        // Custom initialization
//        emailTempArray = (NSMutableArray *)contactArray;
        emailTempArray = [[NSMutableArray alloc] initWithArray:contactArray];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isEditFunnel) {
        isFunnlNameTextFieldEditing = FALSE;
    }
    else {
        isFunnlNameTextFieldEditing = TRUE;
    }
    
    suggestionArray = [[NSArray alloc] initWithObjects:@"Team", @"Clients", @"Friends & Family", @"Spam", @"Event", nil];
    randomColors = GRADIENT_ARRAY;
    if (!subjectString) {
        subjectString = @"";
    }
    enableNotification = TRUE;
    skipPrimary = FALSE;
    isEditing = NO;
    flag = TRUE;
    advanceFlag = FALSE;
    buttonArray = [[NSMutableArray alloc] init];
    
    [self applyBackgroundImage];
    UIBarButtonItem *sampleBarButton = [[UIBarButtonItem alloc] init];
    [sampleBarButton setTarget:self];
    [sampleBarButton setAction:@selector(saveButtonPressed:)];
    [sampleBarButton setTitle:@"Save"];
    [self.navigationItem setRightBarButtonItem:sampleBarButton];
    sampleBarButton = nil;
    [self setUpCustomNavigationBar];
    [self setUpViewForCreatingFunnel];
    [self advanceButtonClicked];
    [self emailContact];
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, HEIGHT - 70)];
    [autocompleteTableView setBackgroundColor:[UIColor whiteColor]];
    [autocompleteTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    autocompleteTableView.dataSource = self;
    autocompleteTableView.delegate = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    autocompleteTableView.tag = 1;
    UIView *footerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [autocompleteTableView setTableFooterView:footerView1];
    footerView1 = nil;
    [mainScrollView addSubview:autocompleteTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if (isEditFunnel) {

    }
    else {
        [funnelNameTextField becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    //    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.view setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark Helper
- (void)controllingSuggestionButton:(NSString *)buttonTitle {
    NSArray *tempArray = [suggestionScroll subviews];
    for (id tempView in tempArray) {
        if ([tempView isKindOfClass:[UIButton class]]) {
            UIButton *sampleButton = tempView;
            if ([sampleButton.titleLabel.text.lowercaseString isEqualToString:buttonTitle.lowercaseString]) {
                sampleButton.layer.borderColor = [[UIColor colorWithHexString:@"007AFF"] CGColor];
                [sampleButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
            }
            else {
                sampleButton.layer.borderColor = [[UIColor whiteColor] CGColor];
                [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setUpSuggestionScrollView:(int)y {
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + 5, WIDTH - 10, 20)];
//    [sampleLabel setFont:[UIFont fontWithName:@"" size:12]];
    [sampleLabel setFont:[UIFont systemFontOfSize:14]];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    sampleLabel.tag = 30000;
    sampleLabel.text = @"Suggestions";
    [sampleLabel setTextColor:[UIColor whiteColor]];
    [mainScrollView addSubview:sampleLabel];
    sampleLabel = nil;
    
    int buttonx = 10;
    suggestionScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y + 30, WIDTH, 70 - 25)];
//    [sampleScrollView setBackgroundColor:[UIColor redColor]];
    [suggestionScroll setUserInteractionEnabled:YES];
    
    int counter = 0;
    
    for (NSString *buttonTitle in suggestionArray) {
        UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonx, 5, [self getWidth:buttonTitle], 35)];
        [sampleButton setTitle:buttonTitle forState:UIControlStateNormal];
        sampleButton.clipsToBounds = YES;
        [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        sampleButton.layer.borderWidth = 1;
        if ([funnelNameTextField.text isEqualToString:buttonTitle]) {
            [sampleButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
            sampleButton.layer.borderColor = [[UIColor colorWithHexString:@"007AFF"] CGColor];
        }
        else {
            [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            sampleButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        }
        sampleButton.layer.cornerRadius = 7.0;
        
        sampleButton.tag = counter;
        counter ++;
        [sampleButton addTarget:self action:@selector(suggestionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [suggestionScroll addSubview:sampleButton];
        sampleButton = nil;
        buttonx = buttonx + [self getWidth:buttonTitle] + 10;
    }
    //    [suggestionScroll setBounces:NO];
    [suggestionScroll setShowsHorizontalScrollIndicator:NO];
    [suggestionScroll setContentSize:CGSizeMake(buttonx, 70 - 25)];
    [mainScrollView addSubview:suggestionScroll];
}

- (CGFloat)getWidth:(NSString *)buttonTitle {
    CGSize myStringSize = [buttonTitle sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(WIDTH, 30) lineBreakMode:NSLineBreakByWordWrapping];
    //    CGSize maximumLabelSize = CGSizeMake(WIDTH, 30);
    //    CGSize myStringSize = [buttonTitle boundingRectWithSize:maximumLabelSize
    //                                                    options:NSStringDrawingUsesLineFragmentOrigin
    //                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
    //                                                    context:nil];
    return myStringSize.width + 20;
}

- (void)applyBackgroundImage {
    AppDelegate *tempAppDelegate = APPDELEGATE;
    UIGraphicsBeginImageContext(tempAppDelegate.window.bounds.size);
    [tempAppDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    UIImageView *backgroundImageView = nil;
    if (backgroundImageView) {
        backgroundImageView = nil;
    }
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [backgroundImageView setImage:[UIImage imageWithData:data]];
    data = nil;
    [self.view addSubview:backgroundImageView];
    FXBlurView *backgroundView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [backgroundView setBlurEnabled:YES];
    backgroundView.tintColor = [UIColor blackColor];
    backgroundView.blurRadius = 10;
    [self.view addSubview:backgroundView];
    backgroundView = nil;
    [backgroundView setUserInteractionEnabled:YES];
    backgroundView = nil;
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

- (BOOL)validateEmailAddress:(NSString*)emailString {
    if([emailString length]){
        NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
        regEx = nil;
        regExPattern = nil;
        if (regExMatches == 0) {
            return NO;
        } else
            return YES;
    }
    else
        return NO;
}

- (void)retrieveContact {
    if (isEditing) {
        [contactMutableArray removeObjectAtIndex:0];
    }
    else {
        if (!contactMutableArray) {
            contactMutableArray = [[NSMutableArray alloc] init];
            for (NSString *emailString in emailTempArray) {
                [self checkForEmailInContact:emailString];
            }
        }
        if (contactMutableArray.count > 0) {
            if ([[[contactMutableArray objectAtIndex:0] name] isEqualToString:ADD_FUNNL]) {
                
            }
            else {
                ContactModel *tempModel = [[ContactModel alloc] init];
                tempModel.name = ADD_FUNNL;
                NSMutableArray *tempArray = nil;
                if (contactMutableArray.count > 0) {
                    tempArray = [[NSMutableArray alloc] initWithArray:contactMutableArray];
                    contactMutableArray = nil;
                    contactMutableArray = [[NSMutableArray alloc] init];
                    [contactMutableArray addObject:tempModel];
                    for (ContactModel *temp in tempArray) {
                        [contactMutableArray addObject:temp];
                    }
                    tempArray = nil;
                }
                else {
                    [contactMutableArray setObject:tempModel atIndexedSubscript:0];
                    tempModel = nil;
                }
            }
        }
        else {
            ContactModel *tempModel = [[ContactModel alloc] init];
            tempModel.name = ADD_FUNNL;
            [contactMutableArray addObject:tempModel];
            tempModel = nil;
        }
//        contactMutableArray = [[NSMutableArray alloc] init];
        
    }
    if (addedContact) {
        [contactMutableArray addObject:addedContact];
        addedContact = nil;
    }
}

- (void)checkForEmailInContact:(NSString *)email {
    NSArray *contactArray = [[ContactService instance] retrieveAllContact];
    BOOL flag11 = FALSE;
    for (ContactModel *tempContact in contactArray) {
        if ([tempContact.email isEqualToString:email]) {
            flag11 = TRUE;
            if (!contactMutableArray) {
                contactMutableArray = [[NSMutableArray alloc] init];
            }
            if (isEditing) {
                [contactMutableArray addObject:tempContact];
            }
            else {
//                if (contactMutableArray.count == 0) {
//                    ContactModel *tempModel = [[ContactModel alloc] init];
//                    tempModel.name = ADD_FUNNL;
//                    [contactMutableArray setObject:tempModel atIndexedSubscript:0];
//                    tempModel = nil;
//                }
                [contactMutableArray addObject:tempContact];
            }
        }
    }
    if (!flag11) {
        ContactModel *tempModel = [[ContactModel alloc] init];
        tempModel.name = email;
        tempModel.email = email;
        [contactMutableArray addObject:tempModel];
        tempModel = nil;
    }
}

- (void)resignAllTextField {
    for (UITextField *tempTextField in textFieldArray) {
        [tempTextField resignFirstResponder];
    }
}

- (UITextField*)getTextFieldForButton:(UIButton*)sender {
    for (UITextField *tempTextField in textFieldArray) {
        if (tempTextField.tag == sender.tag) {
            return tempTextField;
        }
    }
    return nil;
}

- (UIView*)getSeperatorViewForButton:(UIButton*)sender {
    for (UITextField *tempTextField in seperatorViewArray) {
        if (tempTextField.tag == sender.tag) {
            return tempTextField;
        }
    }
    return nil;
}

- (void)moveElementsBelowButton:(UIButton*)sender {
    for (UITextField *tempTextField in textFieldArray) {
        if (sender.tag < tempTextField.tag) {
            tempTextField.frame = CGRectMake(tempTextField.frame.origin.x, tempTextField.frame.origin.y - COMMON_DIFFERENCE - 5, tempTextField.frame.size.width, tempTextField.frame.size.height);
        }
    }
    
    for (UIButton *tempButton in editButtonArray) {
        if (sender.tag < tempButton.tag) {
            tempButton.frame = CGRectMake(tempButton.frame.origin.x, tempButton.frame.origin.y - COMMON_DIFFERENCE - 5, tempButton.frame.size.width, tempButton.frame.size.height);
        }
    }
    
    for (UIView *seperator in seperatorViewArray) {
        if (sender.tag < seperator.tag) {
            seperator.frame = CGRectMake(seperator.frame.origin.x, seperator.frame.origin.y - COMMON_DIFFERENCE - 5, seperator.frame.size.width, seperator.frame.size.height);
        }
    }
}

- (void)setUpViewForCreatingFunnel {
    int y = 0;
    if (mainScrollView) {
        [mainScrollView removeFromSuperview];
        mainScrollView = nil;
    }
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 22, WIDTH, HEIGHT - self.navigationController.navigationBar.frame.size.height - 22)];
    [mainScrollView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    
    UILabel *sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 125, 40)];
    [sampleLAbel setTextAlignment:NSTextAlignmentLeft];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.tag = 1000;
    sampleLAbel.text = @"Funnl Name:";
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    NSString *tempFunnelNameString = nil;
    if (funnelNameTextField) {
        tempFunnelNameString = funnelNameTextField.text;
        subjectString = nil;
        funnelNameTextField = nil;
    }
    
    funnelNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(125, 0, WIDTH - 125 - 10, 40)];
    if (tempFunnelNameString) {
        if (tempFunnelNameString.length) {
            funnelNameTextField.text = tempFunnelNameString;
        }
        else {
            NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter Funnl name"];
            [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter Funnl name".length)];
            [funnelNameTextField setAttributedPlaceholder:tempString];
            tempString = nil;
        }
    }
    else {
        NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter Funnl name"];
        [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter Funnl name".length)];
        [funnelNameTextField setAttributedPlaceholder:tempString];
        tempString = nil;
    }
    funnelNameTextField.tag = 1001;
    funnelNameTextField.delegate = self;
    if (isEditFunnel) {
        funnelNameTextField.text = oldModel.funnelName;
    }
    else {
        if (subjectString) {
            funnelNameTextField.text = subjectString;
        }
    }
    funnelNameTextField.returnKeyType = UIReturnKeyDone;
    [funnelNameTextField setFont:[UIFont boldSystemFontOfSize:18]];
    [funnelNameTextField setTextColor:[UIColor whiteColor]];
    [funnelNameTextField setTextAlignment:NSTextAlignmentLeft];
    [mainScrollView addSubview:funnelNameTextField];
    
    
    if (isFunnlNameTextFieldEditing) {
        [funnelNameTextField becomeFirstResponder];
    }

    
    UIView *sampleView = nil;
    if (isEditFunnel || !isFunnlNameTextFieldEditing || isEditing) {
        sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, 40, 300, 1)];
        [sampleView setBackgroundColor:[UIColor lightGrayColor]];
        sampleView.tag = 1002;
        [mainScrollView addSubview:sampleView];
        sampleView = nil;
        y = y + 40 + 1;
    }
    else {
            y = y + 40;
            [self setUpSuggestionScrollView:y];
            y = y + 70 + 10;
            sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 1)];
            [sampleView setBackgroundColor:[UIColor lightGrayColor]];
            sampleView.tag = 1002;
            [mainScrollView addSubview:sampleView];
            sampleView = nil;
            y = y + 1;
    }
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + 10, 300, 20)];
    if (!isEditFunnel && isEditing) {
        sampleLAbel.frame = CGRectMake(10, y - 25, 300, 20);
    }
    else if (isEditing) {
        sampleLAbel.frame = CGRectMake(10, y - 25, 300, 20);
    }
    sampleLAbel.text = @"Include People:";
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    [sampleLAbel setTextAlignment:NSTextAlignmentLeft];
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    y = y + 20 + 20 + 20;
    
    
    float buttonSize = 75.0;
    int margin = 40;
    //    int xMargine = 10;
    int x = 10;
    //    int yMargine = 10;
    int label_height = 25;
    float color = 255;
    
    UIFont *labelFont = [UIFont systemFontOfSize:13];
    if (emailTempArray.count || addedContact) {
        [self retrieveContact];
    }
    else {
        if (isEditing) {
            if (contactMutableArray.count) {
                [contactMutableArray removeObjectAtIndex:0];
            }
        }
        else {
//            if ([[(ContactModel *)[contactMutableArray objectsAtIndexes:0] name] isEqualToString:ADD_FUNNL]) {
//                
//            }
//            else {
//                ContactModel *tempModel = [[ContactModel alloc] init];
//                tempModel.name = ADD_FUNNL;
//                contactMutableArray = nil;
//                contactMutableArray = [[NSMutableArray alloc] init];
//                [contactMutableArray addObject:tempModel];
//                tempModel = nil;
//            }
            if (!contactMutableArray.count) {
                ContactModel *tempModel = [[ContactModel alloc] init];
                tempModel.name = ADD_FUNNL;
                contactMutableArray = nil;
                contactMutableArray = [[NSMutableArray alloc] init];
                [contactMutableArray addObject:tempModel];
                tempModel = nil;
            }
        }
    }
    
    for (int cnt =0;cnt < fetcherArray.count;cnt++) {
        GTMHTTPFetcher *tempFetcher = [fetcherArray objectAtIndex:cnt];
        [tempFetcher stopFetching];
        [fetcherArray removeObjectAtIndex:cnt];
        tempFetcher = nil;
    }
    
    if (buttonArray) {
        [buttonArray removeAllObjects];
    }
    
    for (int counter = 0; counter < 9 && counter < contactMutableArray.count; counter++) {
        if (counter > 0)
            color = 255/(counter*2);
        unsigned long temp = counter % 8;
        NSString *colorString = [randomColors objectAtIndex:temp];
        UIColor *color = [UIColor colorWithHexString:colorString];
        
        if(color == nil){
            color = [UIColor colorWithHexString:@"#F9F9F9"];
        }
        
        
        ContactModel *tempContact = [contactMutableArray objectAtIndex:counter];
        if ([tempContact.name isEqualToString:ADD_FUNNL]) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
            [tempButton addTarget:self action:@selector(addSender:) forControlEvents:UIControlEventTouchUpInside];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0f;
            tempButton.layer.borderColor = [[UIColor whiteColor] CGColor];
            tempButton.layer.borderWidth = 2;
            [tempButton setBackgroundImage:[UIImage imageNamed:@"addSenderCircle.png"] forState:UIControlStateNormal];
            [buttonArray addObject:tempButton];
            [mainScrollView addSubview:tempButton];
            tempButton = nil;
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 - 5, y + buttonSize + 5, buttonSize + 10, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            sampleLabel.text = @"Add a sender";
            [mainScrollView addSubview:sampleLabel];
            sampleLAbel = nil;
        }
        else {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[(ContactModel*)[contactMutableArray objectAtIndex:counter] thumbnail]]];
            [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            fetcher.comment = [NSString stringWithFormat:@"%d",counter];
            GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
            [fetcher setAuthorizer:currentAuth];
            [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
            if (!fetcherArray) {
                fetcherArray = [[NSMutableArray alloc] init];
            }
            [fetcherArray addObject:fetcher];
            
            if (counter % 3 == 0) {
                UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
                
                if ([[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] length]) {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                else {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                tempButton.tag = counter;
                
                [tempButton setBackgroundColor:color];
                tempButton.clipsToBounds = YES;
                tempButton.layer.cornerRadius = buttonSize/2.0;
                tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
                tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
                [mainScrollView addSubview:tempButton];
                [buttonArray addObject:tempButton];
                tempButton = nil;
                
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(x + buttonSize - 15, y - 18, 30, 30)];
                [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
                closeButton.tag = counter;
                [closeButton addTarget:self action:@selector(deleteContactPressed:) forControlEvents:UIControlEventTouchUpInside];
                [mainScrollView addSubview:closeButton];
                closeButton = nil;
                
                UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + buttonSize + 5, buttonSize, label_height)];
                if (![[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] isEqualToString:@""]) {
                    sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] name];
                }
                else {
                    sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] email];
                }
                [sampleLabel setTextColor:[UIColor whiteColor]];
                sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                [sampleLabel setFont:labelFont];
                [sampleLabel setTextAlignment:NSTextAlignmentCenter];
                [mainScrollView addSubview:sampleLabel];
                sampleLabel = nil;
            }
            else if (counter % 3 == 1) {
                UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y, buttonSize, buttonSize)];
                tempButton.tag = counter;
                if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length) {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                else {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                [tempButton.titleLabel setFont:FONT_FOR_INITIAL];
                [tempButton setBackgroundColor:color];
                tempButton.clipsToBounds = YES;
                tempButton.layer.cornerRadius = buttonSize/2.0;
                tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
                tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
                [mainScrollView addSubview:tempButton];
                [buttonArray addObject:tempButton];
                tempButton = nil;
                
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2 + buttonSize - 18, y - 15, 30, 30)];
                [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
                closeButton.tag = counter;
                [closeButton addTarget:self action:@selector(deleteContactPressed:) forControlEvents:UIControlEventTouchUpInside];
                [mainScrollView addSubview:closeButton];
                closeButton = nil;
                
                UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y + buttonSize + 5, buttonSize, label_height)];
                [sampleLabel setTextColor:[UIColor whiteColor]];
                //            sampleLabel.numberOfLines = 2;
                sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                if (![[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] isEqualToString:@""]) {
                    sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] name];
                }
                else {
                    sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] email];
                }
                [sampleLabel setFont:labelFont];
                [sampleLabel setTextAlignment:NSTextAlignmentCenter];
                [mainScrollView addSubview:sampleLabel];
                sampleLabel = nil;
            }
            else if (counter % 3 == 2) {
                UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y, buttonSize, buttonSize)];
                [tempButton.titleLabel setFont:FONT_FOR_INITIAL];
                tempButton.tag = counter;
                if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length) {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                else {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                [tempButton setBackgroundColor:color];
                tempButton.clipsToBounds = YES;
                tempButton.layer.cornerRadius = buttonSize/2.0;
                tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
                tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
                [mainScrollView addSubview:tempButton];
                [buttonArray addObject:tempButton];
                tempButton = nil;
                
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize + buttonSize - 18, y - 15, 30, 30)];
                [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
                closeButton.tag = counter;
                [closeButton addTarget:self action:@selector(deleteContactPressed:) forControlEvents:UIControlEventTouchUpInside];
                [mainScrollView addSubview:closeButton];
                closeButton = nil;
                
                UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y + buttonSize + 5, buttonSize, label_height)];
                [sampleLabel setTextColor:[UIColor whiteColor]];
                //            sampleLabel.numberOfLines = 2;
                sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                if (![[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] isEqualToString:@""]) {
                    sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] name];
                }
                else {
                    sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] email];
                }
                [sampleLabel setFont:labelFont];
                [sampleLabel setTextAlignment:NSTextAlignmentCenter];
                [mainScrollView addSubview:sampleLabel];
                sampleLabel = nil;
                
                y = y + buttonSize + margin;
            }
        }
    }
    
    if (contactMutableArray.count % 3 == 0) {
        
    }
    else {
        y = y + buttonSize + 20 + 20;
    }
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    [mainScrollView addSubview:sampleView];
    sampleView = nil;
    
    y = y + 1 + 10;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 40 - 10)];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Enable Notifications";
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    UISwitch *notificationEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 10 - 50, y, 70, 40)];
    if (isEditFunnel) {
        [notificationEnableSwitch setOn:oldModel.notificationsFlag animated:YES];
        enableNotification = oldModel.notificationsFlag;
    }
    else
        [notificationEnableSwitch setOn:enableNotification animated:YES];
    [notificationEnableSwitch addTarget:self action:@selector(enableNotificationChanges:) forControlEvents:UIControlEventValueChanged];
    [notificationEnableSwitch setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [mainScrollView addSubview:notificationEnableSwitch];
    notificationEnableSwitch = nil;
    
    y = y + 20 + 20;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    [mainScrollView addSubview:sampleView];
    sampleView = nil;
    
    y = y + 1 + 10;
    
    if (containerView) {
        containerView = nil;
    }
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, WIDTH, 10)];
    
    //    [containerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    innerY = 0;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, innerY, 300, 40)];
    sampleLAbel.text = @"ADVANCED";
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    //    [sampleLAbel setFont:[UIFont boldSystemFontOfSize:20]];
    //    [mainScrollView addSubview:sampleLAbel];
    [containerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    UIImageView *sampleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH - 10 - 18, innerY + 20, 18, 10)];
    [sampleImageView setImage:[UIImage imageNamed:@"expandIcon.png"]];
    [containerView addSubview:sampleImageView];
    sampleImageView = nil;
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, innerY, WIDTH, 40)];
    [sampleButton addTarget:self action:@selector(advanceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [mainScrollView addSubview:sampleButton];
    [containerView addSubview:sampleButton];
    sampleButton = nil;
    
    //    y = y + 40 + 10;
    innerY = innerY + 40 + 10;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, innerY, WIDTH, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    //    [mainScrollView addSubview:sampleView];
    [containerView addSubview:sampleView];
    sampleView = nil;
    
    //    y = y + 1 + 20;
    innerY = innerY + 1 + 20;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, innerY, WIDTH - 20, 15)];
    sampleLAbel.text = @"Include Subject Keywords:";
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    //    [mainScrollView addSubview:sampleLAbel];
    [containerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
//    if (textFieldArray) {
//        [textFieldArray removeAllObjects];
//    }
    
    //    y = y + 15 + 5;
    innerY = innerY + 15 + 10;
    
    if (isEditFunnel) {
        if (subjectArray.count == 0) {
            UITextField *sampleTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, innerY, WIDTH - 20 - 45, 20)];
            sampleTextField.delegate = self;
            sampleTextField.tag = 0;
            sampleTextField.returnKeyType = UIReturnKeyDone;
//            sampleTextField.text = [subjectArray objectAtIndex:counter];
            NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter the subject"];
            [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter the subject".length)];
            [sampleTextField setAttributedPlaceholder:tempString];
            tempString = nil;
            [sampleTextField setTextColor:[UIColor whiteColor]];
            [containerView addSubview:sampleTextField];
            if (!textFieldArray) {
                textFieldArray = [[NSMutableArray alloc] init];
            }
            [textFieldArray addObject:sampleTextField];
            sampleTextField = nil;
            
            sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, innerY + 10 - 30.0/2.0, 30, 30)];
            [sampleButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
            [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [sampleButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
            sampleButton.tag = 0;
            [sampleButton setBackgroundColor:[UIColor clearColor]];
            if (!editButtonArray) {
                editButtonArray = [[NSMutableArray alloc] init];
            }
            [editButtonArray addObject:sampleButton];
            [containerView addSubview:sampleButton];
            sampleButton = nil;
            
            innerY = innerY + 25;
        }
        else {
            if (subjectArray.count) {
                
            }
            if (textFieldArray) {
                textFieldArray = nil;
            }
            textFieldArray = [[NSMutableArray alloc] init];
            
            if (seperatorViewArray) {
                seperatorViewArray = nil;
            }
            seperatorViewArray = [[NSMutableArray alloc] init];
            
            for (int counter = 0; counter < subjectArray.count; counter++) {
                UITextField *sampleTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, innerY, WIDTH - 20 - 45, 20)];
                sampleTextField.text = [subjectArray objectAtIndex:counter];
                sampleTextField.tag = counter;
                [sampleTextField setTextColor:[UIColor whiteColor]];
                if (counter == subjectArray.count) {
                    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, innerY + 10 - 30.0/2.0, 30, 30)];
                    [sampleButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
                    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                    [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                    [sampleButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
                    sampleButton.tag = counter;
                    [sampleButton setBackgroundColor:[UIColor clearColor]];
                    if (!editButtonArray) {
                        editButtonArray = [[NSMutableArray alloc] init];
                    }
                    [editButtonArray addObject:sampleButton];
                    [containerView addSubview:sampleButton];
                    sampleButton = nil;
                }
                else {
                    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, innerY + 25 + 2, WIDTH - 20, 1)];
                    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
                    sampleView.tag = counter;
                    [containerView addSubview:sampleView];
                    if (!seperatorViewArray) {
                        seperatorViewArray = [[NSMutableArray alloc] init];
                    }
                    [seperatorViewArray addObject:sampleView];
                    sampleView = nil;
                    
                    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, innerY + 10 - 30.0/2.0, 30, 30)];
                    [sampleButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
                    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                    [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                    [sampleButton addTarget:self action:@selector(deleteSubject:) forControlEvents:UIControlEventTouchUpInside];
                    sampleButton.tag = counter;
                    [sampleButton setBackgroundColor:[UIColor clearColor]];
                    if (!editButtonArray) {
                        editButtonArray = [[NSMutableArray alloc] init];
                    }
                    [editButtonArray addObject:sampleButton];
                    [containerView addSubview:sampleButton];
                    sampleButton = nil;
                }
                
                [containerView addSubview:sampleTextField];
                
                [textFieldArray addObject:sampleTextField];
                sampleTextField = nil;
                innerY = innerY + 35;
            }
            UITextField *sampleTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, innerY, WIDTH - 20 - 45, 20)];
            sampleTextField.delegate = self;
            sampleTextField.tag = subjectArray.count;
            sampleTextField.returnKeyType = UIReturnKeyDone;
            //            sampleTextField.text = [subjectArray objectAtIndex:counter];
            NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter the subject"];
            [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter the subject".length)];
            [sampleTextField setAttributedPlaceholder:tempString];
            tempString = nil;
            [sampleTextField setTextColor:[UIColor whiteColor]];
            [containerView addSubview:sampleTextField];
            if (!textFieldArray) {
                textFieldArray = [[NSMutableArray alloc] init];
            }
            [textFieldArray addObject:sampleTextField];
            sampleTextField = nil;
            
            sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, innerY + 10 - 30.0/2.0, 30, 30)];
            [sampleButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
            [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [sampleButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
            sampleButton.tag = subjectArray.count;
            [sampleButton setBackgroundColor:[UIColor clearColor]];
            if (!editButtonArray) {
                editButtonArray = [[NSMutableArray alloc] init];
            }
            [editButtonArray addObject:sampleButton];
            [containerView addSubview:sampleButton];
            sampleButton = nil;
            
            innerY = innerY + 25;
        }
    }
    else {
        if (textFieldArray) {
            textFieldArray = nil;
        }
        textFieldArray = [[NSMutableArray alloc] init];
        if (!textFieldArray || !textFieldArray.count) {
            textFieldArray = [[NSMutableArray alloc] init];
            subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, innerY, 300 - 45, 20)];
            subjectTextField.tag = 0;
            //    [subjectTextField setPlaceholder:@"Enter the subject"];
            subjectTextField.returnKeyType = UIReturnKeyDone;
            subjectTextField.delegate = self;
            [textFieldArray addObject:subjectTextField];
            NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter the subject"];
            [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter the subject".length)];
            [subjectTextField setAttributedPlaceholder:tempString];
            tempString = nil;
            [subjectTextField setTextColor:[UIColor whiteColor]];
            //    [mainScrollView addSubview:subjectTextField];
            [containerView addSubview:subjectTextField];
            editButtonArray = [[NSMutableArray alloc] init];
            sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, innerY + 10 - 30.0/2.0, 30, 30)];
            [sampleButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
            [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [sampleButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
            sampleButton.tag = 0;
            [sampleButton setBackgroundColor:[UIColor clearColor]];
            [editButtonArray addObject:sampleButton];
            [containerView addSubview:sampleButton];
//            sampleButton = nil;
            innerY = innerY + 20;
            
            innerY = innerY + 5;
        }
        else {
            for (int counter = 0; counter < textFieldArray.count; counter++) {
                UITextField *tempTextField = [textFieldArray objectAtIndex:counter];
                [containerView addSubview:tempTextField];
                [containerView addSubview:[editButtonArray objectAtIndex:counter]];
//                if (counter == textFieldArray.count - 1) {
//                    innerY = innerY + 30;
//                }
//                
//                else
                    innerY = innerY + 35;
            }
            for (int counter = 0; counter < seperatorViewArray.count; counter++) {
                if (counter < seperatorViewArray.count) {
                    UIView *tempView = [seperatorViewArray objectAtIndex:counter];
                    [containerView addSubview:tempView];
                }
            }
        }
    }
    
    //    y = y + 20;
    
    if (footerView) {
        footerView = nil;
    }
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, innerY, WIDTH, 100)];
    
    int internalY = 0;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, internalY, WIDTH - 20, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    //    [containerView addSubview:sampleView];
    [footerView addSubview:sampleView];
    sampleView = nil;
    
    internalY = internalY + 5;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, internalY, WIDTH - 20, 40)];
    sampleLAbel.numberOfLines = 2;
    [sampleLAbel setFont:[UIFont systemFontOfSize:14]];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Only emails having subjects containing your keywords will be filtered into this Funnel";
    //    [containerView addSubview:sampleLAbel];
    [footerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    internalY = internalY + 40;
    
    internalY = internalY + 5;
    
    
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, internalY, WIDTH - 20, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    //    [containerView addSubview:sampleView];
    [footerView addSubview:sampleView];
    sampleView = nil;
    
    //    innerY = innerY + 5 + 10;
    internalY = internalY + 15;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, internalY, 300, 40 - 10)];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Skip Primary Inbox";
    //    [containerView addSubview:sampleLAbel];
    [footerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    UISwitch *primarySkipSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 10 - 50, internalY, 70, 40)];
    if (isEditFunnel) {
        [primarySkipSwitch setOn:oldModel.skipFlag animated:YES];
    }
    else
        [primarySkipSwitch setOn:skipPrimary animated:YES];
    [primarySkipSwitch addTarget:self action:@selector(skipPrimaryMailChange:) forControlEvents:UIControlEventValueChanged];
    [primarySkipSwitch setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    //    [containerView addSubview:primarySkipSwitch];
    [footerView addSubview:primarySkipSwitch];
    primarySkipSwitch = nil;
    
    //    innerY = innerY + 40;
    internalY = internalY + 40;
    
    
    
    internalY = internalY + 40;
    
    footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y, footerView.frame.size.width, internalY);
    
    innerY = internalY + innerY;
    
    if (isEditFunnel) {
        deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(10, innerY, WIDTH - 20, 30)];
        [deleteButton setTitleColor:DELETE_RED_COLOR forState:UIControlStateNormal];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteFunnel) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.clipsToBounds = YES;
        deleteButton.layer.cornerRadius = 3;
        deleteButton.layer.borderWidth = 1;
        deleteButton.layer.borderColor = [DELETE_RED_COLOR CGColor];
        [mainScrollView addSubview:deleteButton];
    }
    
    containerView.frame = CGRectMake(0, y, WIDTH, innerY + 20);
    
    [containerView setClipsToBounds:YES];
    [containerView addSubview:footerView];
    
    [mainScrollView addSubview:containerView];
    
    [self.view addSubview:mainScrollView];
    if (isEditFunnel) {
        [mainScrollView setContentSize:CGSizeMake(WIDTH, y + innerY + 60)];
    }
    else
        [mainScrollView setContentSize:CGSizeMake(WIDTH, y + innerY)];
    y = y + innerY;
    finalHeight = y;
    [self advanceButtonClicked];
}

- (void)setUpCustomNavigationBar {
    UIView *naviGationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 66)];
//    [naviGationBar setBackgroundColor:[UIColor clearColor]];
    [naviGationBar setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 22, 100, 44)];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [sampleButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 22, 100, 44)];
    [sampleLabel setTextAlignment:NSTextAlignmentCenter];
    sampleLabel.text = @"Create Funnl";
    [sampleLabel setTextColor:[UIColor whiteColor]];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    [naviGationBar addSubview:sampleLabel];
    sampleLabel = nil;
    
    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 100 - 10, 22, 100, 44)];
    [sampleButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setTitle:@"Save" forState:UIControlStateNormal];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [sampleButton setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 2)];
    [sampleView setBackgroundColor:[UIColor whiteColor]];
    [naviGationBar addSubview:sampleView];
    sampleView = nil;
    
    [self.view addSubview:naviGationBar];
}

- (void)removeViewFromMainScroll {
    NSArray *subViews = [mainScrollView subviews];
    for (UIView *tempView in subViews) {
        [tempView removeFromSuperview];
    }
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    // Put anything that starts with this substring into the searchArray
    // The items in this array is what will show up in the table view
    [searchArray removeAllObjects];
    if(substring.length){
        if (emailArr) {
            emailArr = nil;
        }
//        emailArr = [[NSMutableArray alloc] initWithArray:[[ContactService instance] searchContactsWithString:substring]];
        emailArr = [[NSMutableArray alloc] initWithArray:[[ContactService instance] searchContactModelWithString:substring]];
        /*for(NSMutableString *curString in emailArr) {
            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([curString rangeOfString:substring].location == 0) {
                [searchArray addObject:curString];
            }
        }*/
        for(ContactModel *tempModel in emailArr) {
            substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([tempModel.email rangeOfString:substring].location == 0 && ![tempModel.email isEqualToString:[[EmailService instance] userEmailID]]) {
                [searchArray addObject:tempModel];
            }
        }
    }
    if(searchArray.count <= 0){
        autocompleteTableView.hidden = YES;
    }
    else{
        autocompleteTableView.hidden = NO;
        [autocompleteTableView removeFromSuperview];
        [mainScrollView addSubview:autocompleteTableView];
        //dispatch_async(dispatch_get_main_queue(), ^{
        [autocompleteTableView reloadData];
        //});
    }
}

#pragma mark -
#pragma mark Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            
        }
        else {
            [self deleteFunnel:nil];
        }
    }
    else if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        }
        else if (buttonIndex == 1) {
            [additionalTextField resignFirstResponder];
            if (addedContact) {
                addedContact = nil;
            }
            addedContact = [[ContactModel alloc] init];
            NSString *name = [self getUserName:additionalTextField.text];
            if (name) {
                addedContact.name = name;
                name = nil;
            }
            else
                addedContact.name = additionalTextField.text;
            
            addedContact.email = additionalTextField.text;
            
            NSString *url = [self getUserImage:additionalTextField.text];
            if (url) {
                addedContact.thumbnail = url;
                url = nil;
            }
            else
                addedContact.thumbnail = @"";
            BOOL flag1 = FALSE;
            for (ContactModel *temp in contactMutableArray) {
                if ([temp.email isEqualToString:addedContact.email]) {
                    addedContact = nil;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact previously added." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    alert = nil;
                    additionalTextField.text = @"";
                    flag1 = TRUE;
                    //                    return NO;
                }
            }
        }
        isEditing = FALSE;
        [mainScrollView removeFromSuperview];
        [self setUpViewForCreatingFunnel];
        [self advanceButtonClicked];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    additionalTextField.text = [(ContactModel *)[searchArray objectAtIndex:indexPath.row] email];
    autocompleteTableView.hidden = YES;
    [mainScrollView setScrollEnabled:YES];
    [funnelNameTextField setUserInteractionEnabled:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont boldSystemFontOfSize:20];
    sectionHeader.textColor = [UIColor whiteColor];
    sectionHeader.backgroundColor = CLEAR_COLOR;
    sectionHeader.text = @"";
    return sectionHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag == 1)
        return 40;
    return 44;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    if ([additionalTextField isFirstResponder]) {
//        CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//        NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//        [UIView animateWithDuration:duration animations:^{
//            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(50, 0, kbSize.height, 0);
//            [mainScrollView setContentInset:edgeInsets];
//            [mainScrollView setScrollIndicatorInsets:edgeInsets];
//        }];
        CGRect keyboardRect = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
        autocompleteTableView.frame = CGRectMake(autocompleteTableView.frame.origin.x,50 + 20 + 25,autocompleteTableView.frame.size.width,HEIGHT - 70 - _keyboardHeight - 66);
    }
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    if ([additionalTextField isFirstResponder]) {
        NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(50, 0, 0, 0);;
            [mainScrollView setContentInset:edgeInsets];
            [mainScrollView setScrollIndicatorInsets:edgeInsets];
        }];
        _keyboardHeight = 0;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == additionalTextField) {
        [self.view bringSubviewToFront:autocompleteTableView];
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
        if(searchArray.count != 0)
            autocompleteTableView.hidden = NO;
        else
            autocompleteTableView.hidden = YES;
        
        if (range.location == 0 && range.length == 1 && [string isEqualToString:@""]) {
            [addEmailButton setHidden:YES];
        }
        else {
            [addEmailButton setHidden:NO];
        }
    }
    else if (textField == funnelNameTextField) {
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self controllingSuggestionButton:substring];
        substring = nil;
        
    }
    return YES;
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    [self setUpViewForCreatingFunnel];
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [self setUpViewForCreatingFunnel];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [mainScrollView setScrollEnabled:YES];
    if (textField == funnelNameTextField) {
        subjectString = funnelNameTextField.text;
        [textField resignFirstResponder];
        if (!isEditFunnel) {
            isFunnlNameTextFieldEditing = FALSE;
            [self setUpViewForCreatingFunnel];
        }
        return YES;
    }
    else if (additionalTextField == textField) {
        autocompleteTableView.hidden = YES;
        [mainScrollView setScrollEnabled:YES];
        [funnelNameTextField setUserInteractionEnabled:YES];
        if ([self validateEmailAddress:additionalTextField.text]) {
            [textField resignFirstResponder];
            if (addedContact) {
                addedContact = nil;
            }
            addedContact = [[ContactModel alloc] init];
            NSString *name = [self getUserName:textField.text];
            if (name) {
                addedContact.name = name;
                name = nil;
            }
            else
                addedContact.name = textField.text;
            
            addedContact.email = textField.text;
            
            NSString *url = [self getUserImage:textField.text];
            if (url) {
                addedContact.thumbnail = url;
                url = nil;
            }
            else
                addedContact.thumbnail = @"";
            BOOL flag1 = FALSE;
            for (ContactModel *temp in contactMutableArray) {
                if ([temp.email isEqualToString:addedContact.email]) {
                    addedContact = nil;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact previously added." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    alert = nil;
                    additionalTextField.text = @"";
                    flag1 = TRUE;
//                    return NO;
                }
            }
            
            isEditing = FALSE;
            [mainScrollView removeFromSuperview];
            [self setUpViewForCreatingFunnel];
            [self advanceButtonClicked];
            return YES;
        }
        else {
            if ([additionalTextField.text isEqualToString:@""]) {
                isEditing = FALSE;
                [mainScrollView removeFromSuperview];
                [self setUpViewForCreatingFunnel];
                [self advanceButtonClicked];
                return YES;
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You have entered an invalid email address." message:nil delegate:self cancelButtonTitle:@"Re-enter" otherButtonTitles:@"Search as text", nil];
                alertView.tag = 1;
                [alertView show];
                alertView = nil;
            }
        }
        return NO;
    }
    else {
        if (isEditFunnel) {
            if (!subjectArray) {
                subjectArray = [[NSMutableArray alloc] init];
            }
            if (textField.text.length) {
                [subjectArray addObject:textField.text];
            }
        }
    }
    [textField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (mainScrollView.contentSize.height - mainScrollView.contentOffset.y < HEIGHT - 66) {
        [mainScrollView setContentOffset:CGPointMake(0, mainScrollView.contentSize.height - HEIGHT + 66) animated:YES];
    }
    [UIView commitAnimations];
    return YES;
}

- (NSString *)getUserImage:(NSString *)emailAddress {
    NSArray *contactArray = [[ContactService instance] retrieveAllContact];
    for (ContactModel *tempContact in contactArray) {
        if ([tempContact.email isEqualToString:emailAddress]) {
            return tempContact.thumbnail;
        }
    }
    return nil;
}

- (NSString *)getUserName:(NSString *)emailAddress {
    NSArray *contactArray = [[ContactService instance] retrieveAllContact];
    for (ContactModel *tempContact in contactArray) {
        if ([tempContact.email isEqualToString:emailAddress]) {
            return tempContact.name;
        }
    }
    return nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [mainScrollView setScrollEnabled:NO];
    if (textField == funnelNameTextField || textField == additionalTextField) {
        
        if (textField == additionalTextField) {
//            [mainScrollView setScrollEnabled:NO];
            [funnelNameTextField setUserInteractionEnabled:NO];
        }
        else if (textField == funnelNameTextField) {
            if (!isEditFunnel && !isFunnlNameTextFieldEditing) {
                isFunnlNameTextFieldEditing = TRUE;
                [self setUpViewForCreatingFunnel];
                
            }
        }
        return YES;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (HEIGHT == 568) {
        [mainScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y + containerView.frame.origin.y - 200) animated:YES];
    }
    else {
        [mainScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y + containerView.frame.origin.y - 150) animated:YES];
    }
//    [mainScrollView setScrollEnabled:NO];
    [UIView commitAnimations];
    return YES;
}
- (void)imageFetcher:(GTMHTTPFetcher *)imageFetcher finishedWithData:(NSData *)imageData error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
    }
    else {
        NSLog(@"--------> %@",imageFetcher.comment);
        if (imageFetcher.comment.integerValue >= contactMutableArray.count) {
            
        }
        else {
            UIButton *tempButton = [buttonArray objectAtIndex:[imageFetcher.comment integerValue]];
            //        TextFieldCell *tempCell = (TextFieldCell*)[Tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[imageFetcher.comment integerValue] inSection:1]];
            //        [tempCell.thumbnailImageView setImage:[UIImage imageWithData:imageData]];
            [tempButton setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            [tempButton setBackgroundColor:[UIColor clearColor]];
            [tempButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

#pragma mark -
#pragma mark Event Handler
- (void)suggestionButtonPressed:(UIButton *)sender {
    sender.layer.borderColor = [[UIColor colorWithHexString:@"007AFF"] CGColor];
    [sender setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
    funnelNameTextField.text = [suggestionArray objectAtIndex:sender.tag];
    NSArray *subView = [suggestionScroll subviews];
    for (UIButton *tempButton in subView) {
        if (![tempButton isEqual:sender] && [tempButton isKindOfClass:[UIButton class]]) {
            tempButton.layer.borderColor = [[UIColor whiteColor] CGColor];
            [tempButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}


- (void)deleteFunnel {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to delete funnl?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.tag = 0;
    [alertView show];
    alertView = nil;
}

- (void)deleteFunnel:(UIButton *)sender {
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Deleted a Funnl (from settings page)"];
#endif
    
    // if there are webhooks created, delete webhooks first
    if ([oldModel.webhookIds length]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSString *webhookJSONString = [oldModel webhookIds];
        NSData *jsonData = [webhookJSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *webhooks = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
        NSArray *senders = [[webhooks allKeys] copy];
        __block long reqCnt = (long)[senders count];
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
    }
    // if there are no webhooks created, then delete from the database
    else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self deleteOperation];
        });
    }
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Funnl deleteButton pressed"];
#endif
}

- (void)deleteOperation {
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (oldModel.skipFlag) {
        [[MessageFilterXRefService instance] deleteXRefWithFunnelId:oldModel.funnelId];
        [self decrementCounterAgainstTheMessage];
    }
    [[FunnelService instance] deleteFunnel:oldModel.funnelId];
    [[MessageService instance] insertFunnelJsonForMessages];
    [tempAppDelegate.progressHUD show:YES];
    [tempAppDelegate.progressHUD removeFromSuperview];
    NSArray *funnelArray = [[FunnelService instance] allFunnels];
    if (self.mainVCdelegate) {
        tempAppDelegate.currentFunnelString = [[(FunnelModel *)funnelArray[0] funnelName] lowercaseString];
        tempAppDelegate.currentFunnelDS = (FunnelModel *)funnelArray[0];
        [self.mainVCdelegate filterSelected:(FunnelModel *)funnelArray[0]];
    }
    funnelArray = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteContactPressed:(UIButton *)sender {
    
    if (!isEditing) {
        NSString *deletedEmailAddress = [NSString stringWithFormat:@"%@",[(ContactModel *)[contactMutableArray objectAtIndex:sender.tag] email]];
        for (ContactModel *tempModel in contactMutableArray) {
            if ([tempModel.email isEqualToString:deletedEmailAddress]) {
                [contactMutableArray removeObjectIdenticalTo:tempModel];
                break;
            }
        }
        [self removeViewFromMainScroll];
        [self setUpViewForCreatingFunnel];
        [self advanceButtonClicked];
    }
}

- (void)bringViewDown {
    NSArray *subView = [mainScrollView subviews];
    for (UIView *tempView in subView) {
        if (tempView.tag == 1000 || tempView.tag == 1001 || tempView.tag == 1002 || [tempView isEqual:suggestionScroll] || tempView.tag == 30000) {

        }
        else {
            tempView.frame = CGRectMake(tempView.frame.origin.x, tempView.frame.origin.y + 30, tempView.frame.size.width, tempView.frame.size.height);
        }
    }
    if (isEditFunnel) {
        [mainScrollView setContentSize:CGSizeMake(WIDTH, mainScrollView.contentSize.height + 30 + 70)];
    }
    else
        [mainScrollView setContentSize:CGSizeMake(WIDTH, mainScrollView.contentSize.height + 30 + 25)];
    
    if (additionalTextField) {
        [additionalTextField removeFromSuperview];
        additionalTextField = nil;
    }
    additionalTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 50 + 70, 300, 20)];
    if (isEditFunnel) {
        additionalTextField.frame = CGRectMake(10, 50 + 20, 300, 20);
    }
    else {
        additionalTextField.frame = CGRectMake(10, 50 + 20, 300, 25);
    }
    additionalTextField.keyboardType = UIKeyboardTypeEmailAddress;
    additionalTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [additionalTextField setTextColor:[UIColor whiteColor]];
    [additionalTextField becomeFirstResponder];
    NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter the email"];
    [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter the email".length)];
    [additionalTextField setAttributedPlaceholder:tempString];
    tempString = nil;
    additionalTextField.delegate = self;
    additionalTextField.returnKeyType = UIReturnKeyDone;
    [mainScrollView addSubview:additionalTextField];
    
    if (addEmailButton) {
        [addEmailButton removeFromSuperview];
        addEmailButton = nil;
    }
    
    addEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 10 - 45, 50 + 10 - 45.0/2.0 + 25, 45, 45)];
    if (isEditFunnel) {
        addEmailButton.frame = CGRectMake(WIDTH - 10 - 45, 50 + 10 - 45.0/2.0 + 20, 45, 45);
    }
    [addEmailButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
    [mainScrollView addSubview:addEmailButton];
    [addEmailButton addTarget:self action:@selector(addSenderDirectly:) forControlEvents:UIControlEventTouchUpInside];
    addEmailButton.hidden = YES;
    
//    addIcon_white_22x22
    seperatorAdditionalTextField = nil;
    seperatorAdditionalTextField = [[UIView alloc] initWithFrame:CGRectMake(10, 50 + 25 + 25, 300, 1)];
    if (isEditFunnel) {
        seperatorAdditionalTextField.frame = CGRectMake(10, 50 + 25 + 25, 300, 1);
    }
    [seperatorAdditionalTextField setBackgroundColor:[UIColor whiteColor]];
    [mainScrollView addSubview:seperatorAdditionalTextField];
}

- (void)bringViewUp {
    [seperatorAdditionalTextField removeFromSuperview];
    [additionalTextField removeFromSuperview];
    additionalTextField = nil;
    NSArray *subView = [mainScrollView subviews];
    for (UIView *tempView in subView) {
        if (tempView.tag == 1000 || tempView.tag == 1001 || tempView.tag == 1002) {
            
        }
        else {
            tempView.frame = CGRectMake(tempView.frame.origin.x, tempView.frame.origin.y - 30, tempView.frame.size.width, tempView.frame.size.height);
        }
    }
}

- (void)enableNotificationChanges:(UISwitch *)tempSwitch {
    enableNotification = !enableNotification;
}

- (void)skipPrimaryMailChange:(UISwitch *)tempSwitch {
    skipPrimary = !skipPrimary;
}

- (void)addSenderDirectly:(UIButton *)sender {
    if ([self validateEmail:additionalTextField.text]) {
        [additionalTextField resignFirstResponder];
        if (addedContact) {
            addedContact = nil;
        }
        addedContact = [[ContactModel alloc] init];
        NSString *name = [self getUserName:additionalTextField.text];
        if (name) {
            addedContact.name = name;
            name = nil;
        }
        else
            addedContact.name = additionalTextField.text;
        
        addedContact.email = additionalTextField.text;
        
        NSString *url = [self getUserImage:additionalTextField.text];
        if (url) {
            addedContact.thumbnail = url;
            url = nil;
        }
        else
            addedContact.thumbnail = @"";
        BOOL flag1 = FALSE;
        for (ContactModel *temp in contactMutableArray) {
            if ([temp.email isEqualToString:addedContact.email]) {
                addedContact = nil;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact is already present in the funnl." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert = nil;
                additionalTextField.text = @"";
                flag1 = TRUE;
            }
        }
        
        isEditing = FALSE;
        [mainScrollView removeFromSuperview];
        [self setUpViewForCreatingFunnel];
        [self advanceButtonClicked];
        [self addSender:sender];
    }
}

- (void)addSender:(UIButton *)sender {
    [buttonArray removeAllObjects];
    NSArray *subView = [mainScrollView subviews];
    for (UIView *tempView in subView) {
        [tempView removeFromSuperview];
    }
    if ([sender isEqual:addEmailButton]) {
        isEditing = TRUE;
    }
    else
        isEditing = !isEditing;
    [self setUpViewForCreatingFunnel];
    [self advanceButtonClicked];
    [self bringViewDown];
//    [self setUpCustomNavigationBar];
}

- (void)addSubject:(UIButton*)sender {
    if ([[[self getTextFieldForButton:sender] text] length] > 0) {
        flag = FALSE;
        //        [self resignAllTextField];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y + 35, footerView.frame.size.width, footerView.frame.size.height);
        containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, containerView.frame.size.height + 35);
        mainScrollView.contentSize = CGSizeMake(WIDTH, mainScrollView.contentSize.height + 35);
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(10, sender.frame.origin.y + 30 + 10 - 5 - 2, WIDTH - 20, 1)];
        seperatorView.tag = sender.tag;
        [seperatorView setBackgroundColor:[UIColor lightGrayColor]];
        [containerView addSubview:seperatorView];
        if (!seperatorViewArray) {
            seperatorViewArray = [[NSMutableArray alloc] init];
        }
        [seperatorViewArray addObject:seperatorView];
        
        UITextField *sampleTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(10, sender.frame.origin.y + 30 + 10, WIDTH - 20 - 45, 20)];
        sampleTextFiled.returnKeyType = UIReturnKeyDone;
        sampleTextFiled.tag = sender.tag + 1;
        [sampleTextFiled setTextColor:[UIColor whiteColor]];
        sampleTextFiled.delegate = self;
        NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter the subject"];
        [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter the subject".length)];
        [sampleTextFiled setAttributedPlaceholder:tempString];
        tempString = nil;
        [containerView addSubview:sampleTextFiled];
        [sampleTextFiled becomeFirstResponder];
        [textFieldArray addObject:sampleTextFiled];
        sampleTextFiled = nil;
        UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, sender.frame.origin.y + 30 + 5, 30, 30)];
        sampleButton.tag = sender.tag + 1;
        [sampleButton setBackgroundColor:[UIColor clearColor]];
        [sampleButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
        [sampleButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
        [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [containerView addSubview:sampleButton];
        [editButtonArray addObject:sampleButton];
        sampleButton = nil;
        deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, deleteButton.frame.origin.y + 35, deleteButton.frame.size.width, deleteButton.frame.size.height);
        [UIView commitAnimations];
        [sender removeTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
        [sender addTarget:self action:@selector(deleteSubject:) forControlEvents:UIControlEventTouchUpInside];
        [sender setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor clearColor]];
        
        if (isEditFunnel) {
            if (!subjectArray) {
                subjectArray = [[NSMutableArray alloc] init];
            }
            if ([[self getTextFieldForButton:sender] text].length) {
                [subjectArray addObject:[[self getTextFieldForButton:sender] text]];
            }
        }
    }
}

- (void)deleteSubject:(UIButton *)sender {
    UIView *seperatorView = [self getSeperatorViewForButton:sender];
//    NSLog(@"tag -- > %d",sender.tag);
    if (seperatorView) {
        [seperatorView removeFromSuperview];
        [seperatorViewArray removeObjectIdenticalTo:seperatorView];
    }
    
    UITextField *tempTextField = [self getTextFieldForButton:sender];
    if (tempTextField) {
        [tempTextField removeFromSuperview];
        [textFieldArray removeObjectIdenticalTo:tempTextField];
    }
    
    if (isEditFunnel) {
        NSLog(@"%@",tempTextField.text);
        for (NSString *tempString in subjectArray) {
            if ([tempString isEqualToString:tempTextField.text]) {
                [subjectArray removeObjectIdenticalTo:tempString];
                break;
            }
        }
    }
    
    [self resignAllTextField];
    [[self getTextFieldForButton:sender] removeFromSuperview];
    [sender removeFromSuperview];
    [textFieldArray removeObjectIdenticalTo:[self getTextFieldForButton:sender]];
    [editButtonArray removeObjectIdenticalTo:sender];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self moveElementsBelowButton:sender];
    footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y - 35, footerView.frame.size.width, footerView.frame.size.height);
    containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, containerView.frame.size.height - 35);
    mainScrollView.contentSize = CGSizeMake(WIDTH, mainScrollView.contentSize.height - 35);
    deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, deleteButton.frame.origin.y - 35, deleteButton.frame.size.width, deleteButton.frame.size.height);
    [UIView commitAnimations];
    [sender removeTarget:self action:@selector(deleteSubject:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)advanceButtonClicked:(UIButton*)sender {
    if (advanceFlag) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        containerView.frame = CGRectMake(0, containerView.frame.origin.y, containerView.frame.size.width, 50);
        deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, containerView.frame.origin.y + 50 + 10, deleteButton.frame.size.width, deleteButton.frame.size.height);
        [UIView commitAnimations];
        advanceFlag = FALSE;
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        containerView.frame = CGRectMake(0, containerView.frame.origin.y, containerView.frame.size.width, innerY);
        deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, containerView.frame.origin.y + innerY + 10, deleteButton.frame.size.width, deleteButton.frame.size.height);
        [UIView commitAnimations];
        advanceFlag = TRUE;
    }
}

- (void)advanceButtonClicked{
    if (!advanceFlag) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        containerView.frame = CGRectMake(0, containerView.frame.origin.y, containerView.frame.size.width, 50);
        deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, containerView.frame.origin.y + 50 + 10, deleteButton.frame.size.width, deleteButton.frame.size.height);
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        containerView.frame = CGRectMake(0, containerView.frame.origin.y, containerView.frame.size.width, innerY);
        deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, containerView.frame.origin.y + innerY + 10, deleteButton.frame.size.width, deleteButton.frame.size.height);
        [UIView commitAnimations];
        advanceFlag = TRUE;
    }
}


- (void)cancelButtonPressed:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //newly added for VIP funnl
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_VIP_ENABLED) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)showHUD {
    AppDelegate *tempAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:tempAppDelegate.window animated:YES];
}

- (void)saveButtonPressed:(UIButton*)sender {
    
    [self performSelectorInBackground:@selector(showHUD) withObject:nil];
    if (senderArray) {
        senderArray = nil;
    }
    senderArray = [[NSMutableArray alloc] init];
    for (ContactModel *tempContact in contactMutableArray) {
        if ([tempContact.name isEqualToString:ADD_FUNNL] || [tempContact.email isEqualToString:@""]) {
            
        }
        else {
            [senderArray addObject:tempContact.email];
        }
    }

    if (subjectArray) {
        subjectArray = nil;
    }
    subjectArray = [[NSMutableArray alloc] init];
    for (UITextField *tempTextField in textFieldArray) {
        if (tempTextField.text.length == 0) {
            
        }
        else {
            [subjectArray addObject:tempTextField.text];
        }
    }
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"Save Butoon pressed");
    
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Created a new Funnl or modified existing Funnl"];
#endif
    
    NSString *funnlName = funnelNameTextField.text;
    if(funnelNameTextField.text.length){
        int validCode = [self validateFunnelName:funnlName];
        if (validCode != 1 && !isEditFunnel) {
            if (validCode == 2) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FUNNEL_NAME_REPEATED message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
                [appDelegate.progressHUD setHidden:YES];
                [appDelegate.progressHUD removeFromSuperview];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            }
            else if (validCode == 3) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FUNNEL_NAME_BLANK message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
                [appDelegate.progressHUD setHidden:YES];
                [appDelegate.progressHUD removeFromSuperview];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            }
            return;
        }
        if((contactMutableArray.count > 0 || (![[(ContactModel *)[contactMutableArray objectAtIndex:0] name] isEqualToString:ADD_FUNNL] && contactMutableArray.count == 1)) || subjectArray.count){
//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if (!enableNotification) {
                if ([oldModel.webhookIds length]) {
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
                                    [self saveFunnlWithWebhookId:nil];
                                }
                            });
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            reqCnt--;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //[self showAlertForError:error];
                                if (reqCnt == 0) {
                                    [self saveFunnlWithWebhookId:nil];
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                }
                            });
                        }];
                    }
                } else {
                    [self saveFunnlWithWebhookId:nil];
                }
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
                    if (senderArray.count) {
                        [self createWebhooksAndSaveFunnl];
                    }
                    else {
                        [self saveFunnlWithWebhookId:nil];
                    }
                }
                
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Please add at least one email or subject" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Please add name for Funnl" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    [appDelegate.progressHUD setHidden:YES];
    [appDelegate.progressHUD removeFromSuperview];
    [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
}

-(void) saveFunnlWithWebhookId:(NSString *) webhookId
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    NSString *colorString = @"#F9F9F9";
    UIColor *color = [UIColor colorWithHexString:colorString];
    if(isEditFunnel){
        color = oldModel.barColor;
        colorString = oldModel.funnelColor;
    }
    else{
        colorString = [randomColors objectAtIndex:temp];
        UIColor *color = [UIColor colorWithHexString:colorString];
        if(color == nil){
            color = [UIColor colorWithHexString:@"#F9F9F9"];
        }
    }
    FunnelModel *model;
    model = [[FunnelModel alloc]initWithBarColor:color filterTitle:funnelNameTextField.text newMessageCount:0 dateOfLastMessage:[NSDate new] sendersArray:senderArray subjectsArray:subjectArray skipAllFlag:skipPrimary funnelColor:colorString];
    model.funnelId = oldModel.funnelId;
    model.notificationsFlag = enableNotification;
    model.webhookIds = webhookId ? webhookId : @"";
    model.skipFlag = skipPrimary;
    
    if(isEditFunnel){
        //                [EmailService editFilter:model withOldFilter:oldModel];
        // save to db
        
        [[MessageFilterXRefService instance] deleteXRefWithFunnelId:model.funnelId];
        [[FunnelService instance] updateFunnel:model];
        [[EmailService instance] applyingFunnel:model toMessages:[[MessageService instance] messagesAllTopMessages]];
        
        if (oldModel.skipFlag == skipPrimary) {
            NSLog(@"No changes had occured!!");
        }
        else {
            if (skipPrimary) {
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
        
        if (skipPrimary) {
            //                    [self incrementCounterAgainstTheMessage];
        }
        else {
            
        }
        [EmailService setNewFilterModel:model];
        // save to db
        
    }
    if (self.mainVCdelegate) {
        [EmailService instance].filterMessages = (NSMutableArray*)[[MessageService instance] messagesWithFunnelId:model.funnelId top:2000];
        [self.mainVCdelegate filterSelected:model];
        tempAppDelegate.currentFunnelString = model.funnelName.lowercaseString;
        tempAppDelegate.currentFunnelDS = model;
    }
    else {
        [tempAppDelegate.mainVCdelegate filterSelected:tempAppDelegate.currentFunnelDS];
    }
    model = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //[[CIOExampleAPIClient sharedClient] clearCredentials];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) createWebhooksAndSaveFunnl
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray *senders = senderArray;
    NSArray *subjects = subjectArray;
    __block int reqCnt = (int)[senders count];
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
