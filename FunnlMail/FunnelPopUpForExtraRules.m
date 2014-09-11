//
//  FunnelPopUpForExtraRules.m
//  FunnlMail
//
//  Created by iauro001 on 6/23/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnelPopUpForExtraRules.h"
#import <Mixpanel/Mixpanel.h>
#import "FXBlurView.h"
static NSString *CONTACT_CELL = @"ContactTableViewCell";
static NSString *contactCellIdentifier = @"ContactCell";
@implementation FunnelPopUpForExtraRules
@synthesize backgroundImageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withMessage:(MCOIMAPMessage*)messages withFunnel:(FunnelModel*)funnelDS onViewController:(id)someViewController
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        message = messages;
        tempFunnelModel = funnelDS;
        AppDelegate *tempAppDelegate = APPDELEGATE;
        
        UIGraphicsBeginImageContext(tempAppDelegate.window.bounds.size);
        [tempAppDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData * data = UIImagePNGRepresentation(image);
        if (backgroundImageView) {
            backgroundImageView = nil;
        }
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [backgroundImageView setImage:[UIImage imageWithData:data]];
        data = nil;
        [self addSubview:backgroundImageView];
        FXBlurView *backgroundView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [backgroundView setBlurEnabled:YES];
        backgroundView.tintColor = [UIColor blackColor];
        backgroundView.blurRadius = 10;
        [self addSubview:backgroundView];
        backgroundView = nil;
        [backgroundView setUserInteractionEnabled:YES];
        backgroundView = nil;
        
        [self setUpViews];
        [self setUpCustomNavigationBar];
        viewController = someViewController;
    }
    return self;
}

#pragma mark -
#pragma mark Helper
- (BOOL)checkForDuplicatesForEmail:(NSString*)address {
    for ( int counter = 0; counter < tempFunnelModel.sendersArray.count ; counter++ ) {
        if ([address isEqualToString:[tempFunnelModel.sendersArray objectAtIndex:counter]] || [address isEqualToString:[EmailService instance].userEmailID]) {
            return TRUE;
        }
    }
    return FALSE;
}

- (void)setUpCustomNavigationBar {
    UIView *naviGationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 66)];
    [naviGationBar setBackgroundColor:[UIColor clearColor]];
//    [naviGationBar setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 22, 80
                                                                        , 44)];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [sampleButton setTitle:@"Undo" forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110 - 25, 22, 150, 44)];
    [sampleLabel setTextAlignment:NSTextAlignmentCenter];
    sampleLabel.text = @"Added to Funnl";
    [sampleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [sampleLabel setTextColor:[UIColor whiteColor]];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    [naviGationBar addSubview:sampleLabel];
    sampleLabel = nil;
    
//    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 100 - 10, 22, 100, 44)];
//    [sampleButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [sampleButton setTitle:@"Save" forState:UIControlStateNormal];
//    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [sampleButton setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE] forState:UIControlStateNormal];
//    [naviGationBar addSubview:sampleButton];
//    sampleButton = nil;
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, WIDTH, 1)];
    [sampleView setBackgroundColor:[UIColor whiteColor]];
    [naviGationBar addSubview:sampleView];
    sampleView = nil;
    
    [self addSubview:naviGationBar];
}

- (void)setUpViews
{
    int y = 0;
    
    //    int width = 280;
    UIButton *outterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [outterButton addTarget:self action:@selector(outterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:outterButton];
    self.backgroundColor = [UIColor clearColor];
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    //    [mainView setBackgroundColor:[UIColor colorWithHexString:@"#E2E2E2"]];
    mainView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    unsigned long temp = 2 % 8;
    NSArray *randomColors = GRADIENT_ARRAY;
    NSString *colorString = [randomColors objectAtIndex:temp];
    randomColors = nil;
    UIColor *color = [UIColor colorWithHexString:colorString];
    
    userButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH - 75)/2.0, 66 + (95 - 75)/2, 75, 75)];
    userButton.clipsToBounds = YES;
    userButton.layer.cornerRadius = 75.0/2.0;
    userButton.layer.borderColor = [[UIColor clearColor] CGColor];
    userButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
    [userButton setBackgroundColor:color];
    
    [userButton.titleLabel setFont:FONT_FOR_INITIAL];
    
    color = nil;
    colorString = nil;
    randomColors = nil;
    
    if (message.header.sender.displayName) {
        [userButton setTitle:[[message.header.sender.displayName substringWithRange:NSMakeRange(0, 1)] uppercaseString] forState:UIControlStateNormal];
//        [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[[contactInCC objectAtIndex:counter] displayName] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
    }
    else {
        [userButton setTitle:[[message.header.sender.mailbox substringWithRange:NSMakeRange(0, 1)] uppercaseString] forState:UIControlStateNormal];
    }
//    [userButton setTitle:@"S" forState:UIControlStateNormal];
    [mainView addSubview:userButton];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self getUserImage:message.header.sender.mailbox]]];
    [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
    [fetcher setAuthorizer:currentAuth];
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
    fetcher.comment = @"-1";
    
    y = 95 + 66;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, WIDTH - 20, 50)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextColor:[UIColor whiteColor]];
    [messageLabel setTextAlignment:NSTextAlignmentLeft];
    messageLabel.numberOfLines = 2;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    if (message.header.sender.displayName) {
        messageLabel.text = [NSString stringWithFormat:@"Messages from %@ will be funneled under %@.",message.header.sender.displayName,tempFunnelModel.funnelName];
    }
    else {
        
        messageLabel.text = [NSString stringWithFormat:@"Messages from %@ will be funneled under %@.",message.header.sender.mailbox,tempFunnelModel.funnelName];
    }
    [messageLabel setFont:[UIFont systemFontOfSize:20]];
    [mainView addSubview:messageLabel];
    messageLabel = nil;
    
    y = y + 50 + 10;
    contactInCC = [[NSMutableArray alloc] initWithArray:message.header.cc];
    for (MCOAddress *tempAddress in contactInCC) {
        if ([tempAddress.mailbox isEqualToString:[[EmailService instance] userEmailID]]) {
            [contactInCC removeObjectIdenticalTo:tempAddress];
        }
    }
    for (int count = 0; count < contactInCC.count; count++) {
        for (int cnt = 0; cnt < tempFunnelModel.sendersArray.count; cnt ++) {
            if ([[[contactInCC objectAtIndex:count] mailbox] isEqualToString:[[tempFunnelModel sendersArray] objectAtIndex:cnt]]) {
                [contactInCC removeObjectAtIndex:count];
            }
        }
    }
    flagArray = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < contactInCC.count; counter++) {
        [flagArray setObject:@"0" atIndexedSubscript:counter];
    }
    
    for ( int counter = 0 ; counter < contactInCC.count ; counter++ ) {
        NSString *ccEmailAddress = [contactInCC objectAtIndex:counter];
        if (![self checkForDuplicatesForEmail:[(MCOAddress*)ccEmailAddress mailbox]]) {
            if (!dataSourceArray) {
                dataSourceArray = [[NSMutableArray alloc] init];
            }
            [dataSourceArray addObject:[(MCOAddress*)ccEmailAddress mailbox]];
        }
    }
    
    if (contactInCC.count) {
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(10, y, WIDTH - 20, 1)];
        [seperator setBackgroundColor:[UIColor lightGrayColor]];
        [mainView addSubview:seperator];
        seperator = nil;
        
        y = y + 0.5 + 10;
        
        alsoAddLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, WIDTH - 20, 20)];
        alsoAddLabel.textAlignment = NSTextAlignmentLeft;
        alsoAddLabel.text = @"Also include:";
        [alsoAddLabel setBackgroundColor:[UIColor clearColor]];
        [alsoAddLabel setTextColor:[UIColor whiteColor]];
        [mainView addSubview:alsoAddLabel];
        alsoAddLabel = nil;
        y = y + 40;
    }
    
    if (!IS_NEW_CREATE_FUNNEL) {
        contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, WIDTH, HEIGHT - y - 50)];
        [contactsTableView setBackgroundColor:CLEAR_COLOR];
        [contactsTableView setSeparatorInset:UIEdgeInsetsZero];
        [contactsTableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:CONTACT_CELL];
        [contactsTableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:contactCellIdentifier];
        contactsTableView.delegate = self;
        contactsTableView.dataSource = self;
        [contactsTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
        [mainView addSubview:contactsTableView];
    }
    else {
        if (buttonArray) {
            buttonArray = nil;
        }
        buttonArray = [[NSMutableArray alloc] init];
        UIFont *labelFont = [UIFont systemFontOfSize:13];
        UIScrollView *ccScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, WIDTH, HEIGHT - y - 50)];
        [ccScrollView setBackgroundColor:[UIColor clearColor]];
        int x1 = 10;
        int y1 = 20;
        int buttonWidth = 75;
        for (int counter = 0; counter < contactInCC.count; counter++) {
            unsigned long temp = counter % 8;
            NSArray *randomColors = GRADIENT_ARRAY;
            NSString *colorString = [randomColors objectAtIndex:temp];
            randomColors = nil;
            UIColor *color = [UIColor colorWithHexString:colorString];
            
            if(color == nil){
                color = [UIColor colorWithHexString:@"#F9F9F9"];
            }
            
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self getUserImage:[[contactInCC objectAtIndex:counter] mailbox]]]];
            [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
            [fetcher setAuthorizer:currentAuth];
            fetcher.comment = [NSString stringWithFormat:@"%d",counter];
            [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
            
            NSString *contactName = [self getUserName:[[contactInCC objectAtIndex:counter] mailbox]];
            
            if (counter % 3 == 0) {
                UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(x1, y1, buttonWidth, buttonWidth)];
                [tempButton.titleLabel setFont:FONT_FOR_INITIAL];
                if ([[contactInCC objectAtIndex:counter] displayName]) {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[[contactInCC objectAtIndex:counter] displayName] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                else {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[[contactInCC objectAtIndex:counter] mailbox] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                
                tempButton.tag = counter;
                [tempButton addTarget:self action:@selector(ccContactPressed:) forControlEvents:UIControlEventTouchUpInside];
                tempButton.clipsToBounds = YES;
                tempButton.layer.borderColor = [[UIColor whiteColor] CGColor];
                tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
                tempButton.layer.cornerRadius = buttonWidth/2.0;
                [ccScrollView addSubview:tempButton];
                [tempButton setBackgroundColor:color];
                [buttonArray addObject:tempButton];
                
                
                
                UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(tempButton.frame.origin.x, tempButton.frame.origin.y + buttonWidth + 5, buttonWidth, 20)];
                [sampleLabel setTextAlignment:NSTextAlignmentCenter];
                [sampleLabel setFont:labelFont];
//                if ([[contactInCC objectAtIndex:counter] displayName]) {
//                    sampleLabel.text = [[contactInCC objectAtIndex:counter] displayName];
//                }
//                else {
//                    sampleLabel.text = [[contactInCC objectAtIndex:counter] mailbox];
//                }
                if (contactName) {
                    sampleLabel.text = contactName;
                }
                else {
                    sampleLabel.text = [[contactInCC objectAtIndex:counter] mailbox];
                }
                [sampleLabel setTextColor:[UIColor whiteColor]];
                [ccScrollView addSubview:sampleLabel];
                sampleLabel = nil;
                tempButton = nil;
            }
            else if (counter % 3 == 1) {
                UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(160 - (buttonWidth/2.0), y1, buttonWidth, buttonWidth)];
                tempButton.clipsToBounds = YES;
                [tempButton.titleLabel setFont:FONT_FOR_INITIAL];
                if ([[contactInCC objectAtIndex:counter] displayName]) {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[[contactInCC objectAtIndex:counter] displayName] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                else {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[[contactInCC objectAtIndex:counter] mailbox] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                tempButton.tag = counter;
                [tempButton setBackgroundColor:color];
                [tempButton addTarget:self action:@selector(ccContactPressed:) forControlEvents:UIControlEventTouchUpInside];
                tempButton.layer.borderColor = [[UIColor whiteColor] CGColor];
                tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
                tempButton.layer.cornerRadius = buttonWidth/2.0;
                [ccScrollView addSubview:tempButton];
                //            tempButton = nil;
                
                [buttonArray addObject:tempButton];
                
                UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(tempButton.frame.origin.x, tempButton.frame.origin.y + buttonWidth + 5, buttonWidth, 20)];
                [sampleLabel setFont:labelFont];
                [sampleLabel setTextAlignment:NSTextAlignmentCenter];
                if (contactName) {
                    sampleLabel.text = contactName;
                }
                else {
                    sampleLabel.text = [[contactInCC objectAtIndex:counter] mailbox];
                }
                [sampleLabel setTextColor:[UIColor whiteColor]];
                [ccScrollView addSubview:sampleLabel];
                sampleLabel = nil;
                tempButton = nil;
            }
            else {
                UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonWidth, y1, buttonWidth, buttonWidth)];
                tempButton.clipsToBounds = YES;
                [tempButton.titleLabel setFont:FONT_FOR_INITIAL];
                if ([[contactInCC objectAtIndex:counter] displayName]) {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[[contactInCC objectAtIndex:counter] displayName] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                else {
                    [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[[contactInCC objectAtIndex:counter] mailbox] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
                }
                
                tempButton.tag = counter;
                [tempButton setBackgroundColor:color];
                [tempButton addTarget:self action:@selector(ccContactPressed:) forControlEvents:UIControlEventTouchUpInside];
                tempButton.layer.borderColor = [[UIColor whiteColor] CGColor];
                tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
                tempButton.layer.cornerRadius = buttonWidth/2.0;
                [ccScrollView addSubview:tempButton];
                y1 = y1 + 100;
                
                [buttonArray addObject:tempButton];
                
                UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(tempButton.frame.origin.x, tempButton.frame.origin.y + buttonWidth + 5, buttonWidth, 20)];
                [sampleLabel setFont:labelFont];
                [sampleLabel setTextAlignment:NSTextAlignmentCenter];
                if (contactName) {
                    sampleLabel.text = contactName;
                }
                else {
                    sampleLabel.text = [[contactInCC objectAtIndex:counter] mailbox];
                }
                [sampleLabel setTextColor:[UIColor whiteColor]];
                [ccScrollView addSubview:sampleLabel];
                sampleLabel = nil;
                tempButton = nil;
            }
        }
        [ccScrollView setContentSize:CGSizeMake(WIDTH, y1)];
        
        [mainView addSubview:ccScrollView];
    }
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(75, HEIGHT - 45, WIDTH - 150, 30)];
    if (contactInCC.count == 0) {
        doneButton.frame = CGRectMake(75, y + 30, WIDTH - 150, 30);
    }
    [doneButton setBackgroundColor:[UIColor clearColor]];
    [doneButton addTarget:self action:@selector(updateFunnel:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.clipsToBounds = YES;
    doneButton.layer.cornerRadius = 2.0;
    doneButton.layer.borderWidth = 1;
    doneButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [mainView addSubview:doneButton];
    
//    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    closeButton.frame = CGRectMake(WIDTH-40, 70, 40, 40);
//    [closeButton setImage:[UIImage imageNamed:@"MPCloseBtn"] forState:UIControlStateNormal];
//    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [mainView addSubview:closeButton];

    mainView.center = self.center;
    
    [self addSubview:mainView];
}

-(void)closeButtonClicked:(id)sender{
    [self setHidden:YES];
}

- (void)ccContactPressed:(UIButton *)sender {
    if ([[flagArray objectAtIndex:sender.tag] isEqualToString:@"0"]) {
        sender.layer.borderColor = [[UIColor colorWithHexString:BUTTON_BORDER_COLOR_SELECTED] CGColor];
        [flagArray setObject:@"1" atIndexedSubscript:sender.tag];
    }
    else {
        sender.layer.borderColor = [[UIColor whiteColor] CGColor];
        [flagArray setObject:@"0" atIndexedSubscript:sender.tag];
    }
}

- (void)imageFetcher:(GTMHTTPFetcher *)imageFetcher finishedWithData:(NSData *)imageData error:(NSError *)error {
    if (error) {
        
    }
    else {
        if ([imageFetcher.comment isEqualToString:@"-1"]) {
            [userButton setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            [userButton setBackgroundColor:[UIColor clearColor]];
            [userButton setTitle:@"" forState:UIControlStateNormal];
        }
        else {
            if (buttonArray.count > [imageFetcher.comment integerValue]) {
                NSLog(@"----> %@",imageFetcher.comment);
                UIButton *sampleButton = [buttonArray objectAtIndex:[imageFetcher.comment integerValue]];
                [sampleButton setTitle:@"" forState:UIControlStateNormal];
                [sampleButton setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            }
            else {
                
            }
        }
    }
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

#pragma mark -
#pragma mark Event Handlers
- (void)updateFunnel:(UIButton*)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    [self performSelector:@selector(updateFunnelData) withObject:nil afterDelay:0.1];
    
}

-(void)updateFunnelData{
    
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Updated Funnl"];
#endif
    NSMutableString *senderString = [[NSMutableString alloc] init];
    for (int counter =0 ; counter < contactInCC.count; counter++) {
        ContactTableViewCell *tempCell = (ContactTableViewCell*)[contactsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:counter inSection:0]];
        NSString *selectEmail = tempCell.nameLabel.text;
        BOOL duplicate = FALSE;
        if ([[flagArray objectAtIndex:counter] isEqualToString:@"1"]) {
            for (NSString *email in tempFunnelModel.sendersArray) {
                if ([email isEqualToString:selectEmail]) {
                    duplicate = TRUE;
                    break;
                }
            }
            if ([[flagArray objectAtIndex:counter] isEqualToString:@"1"] && !duplicate) {
                [senderString appendFormat:@"%@,",[[contactInCC objectAtIndex:counter] mailbox]];
            }
        }
    }
    if (senderString.length > 0) {
        senderString = (NSMutableString*)[senderString substringWithRange:NSMakeRange(0, senderString.length -1)];
        tempFunnelModel.emailAddresses = [NSString stringWithFormat:@"%@,%@",tempFunnelModel.emailAddresses,senderString];
    }
    if ([tempFunnelModel.emailAddresses rangeOfString:message.header.sender.mailbox].location == NSNotFound) {
        tempFunnelModel.emailAddresses = [NSString stringWithFormat:@"%@,%@",tempFunnelModel.emailAddresses,message.header.sender.mailbox];
    } else {
        
    }
    NSLog(@"CC %@",tempFunnelModel.emailAddresses);
    [[FunnelService instance] updateFunnel:tempFunnelModel];
    [[EmailService instance] applyingFunnel:tempFunnelModel toMessages:[EmailService instance].filterMessages];
    [self removeFromSuperview];
    [[(EmailsTableViewController*)viewController tableView] reloadData];
    AppDelegate *tempAppDelegate = APPDELEGATE;
    tempAppDelegate.funnelUpDated = TRUE;
    [MBProgressHUD hideAllHUDsForView:tempAppDelegate.window animated:YES];
}

- (void)outterButtonClicked:(UIButton *)sender {
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Clicked away from funnlPopUp"];
#endif
    [self removeFromSuperview];
    [[(EmailsTableViewController*)viewController tableView] reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (dataSourceArray.count > 0) {
        return dataSourceArray.count;
    }
    return 0;
}

- (ContactTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCellIdentifier forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.nameLabel.text = [dataSourceArray objectAtIndex:indexPath.row];
    if ([[flagArray objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
//        [cell.selectionIndicator setBackgroundColor:[UIColor clearColor]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
//        [cell.selectionIndicator setBackgroundColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *tempCell = (ContactTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([[flagArray objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
        [flagArray setObject:@"0" atIndexedSubscript:indexPath.row];
        tempCell.flag = FALSE;
//        [tempCell.selectionIndicator setBackgroundColor:[UIColor clearColor]];
        NSIndexPath* rowToReload = indexPath;
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        [tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        rowsToReload = nil;
        rowToReload = nil;
    }
    else
    {
        [flagArray setObject:@"1" atIndexedSubscript:indexPath.row];
        tempCell.flag = TRUE;
//        [tempCell.selectionIndicator setBackgroundColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
        NSIndexPath* rowToReload = indexPath;
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        [tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        rowsToReload = nil;
        rowToReload = nil;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [contactsTableView reloadData];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *tempCell = (ContactTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (tempCell.flag) {
        tempCell.flag = FALSE;
        //[tempCell.selectionIndicator setBackgroundColor:[UIColor clearColor]];
        tempCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        tempCell.flag = TRUE;
        [tempCell.selectionIndicator setBackgroundColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
        tempCell.accessoryType = UITableViewCellAccessoryCheckmark;

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
