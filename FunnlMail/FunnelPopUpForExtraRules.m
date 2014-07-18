//
//  FunnelPopUpForExtraRules.m
//  FunnlMail
//
//  Created by iauro001 on 6/23/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnelPopUpForExtraRules.h"
#import <Mixpanel/Mixpanel.h>
static NSString *CONTACT_CELL = @"ContactTableViewCell";
static NSString *contactCellIdentifier = @"ContactCell";
@implementation FunnelPopUpForExtraRules

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
        [self setUpViews];
        viewController = someViewController;
    }
    return self;
}

#pragma mark -
#pragma mark Helper
- (void)setUpViews
{
    int width = 280;
    UIButton *outterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [outterButton addTarget:self action:@selector(outterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:outterButton];
    self.backgroundColor = [UIColor clearColor];
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//    [mainView setBackgroundColor:[UIColor colorWithHexString:@"#E2E2E2"]];
    mainView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.93];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 70, WIDTH - 16 - 40, 50)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextColor:[UIColor whiteColor]];
    [messageLabel setTextAlignment:NSTextAlignmentLeft];
    messageLabel.numberOfLines = 2;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    if (message.header.sender.displayName) {
        messageLabel.text = [NSString stringWithFormat:@"Message from %@ will be funneled under %@.",message.header.sender.displayName,tempFunnelModel.funnelName];
    }
    else {
        messageLabel.text = [NSString stringWithFormat:@"Message from %@ will be funneled under %@.",message.header.sender.mailbox,tempFunnelModel.funnelName];
    }
    
    [mainView addSubview:messageLabel];
    messageLabel = nil;
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 140, WIDTH, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [mainView addSubview:seperator];
    seperator = nil;
    
    alsoAddLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, WIDTH, 40)];
    alsoAddLabel.textAlignment = NSTextAlignmentCenter;
    alsoAddLabel.text = @"Also add?";
    [alsoAddLabel setBackgroundColor:[UIColor clearColor]];
    [alsoAddLabel setTextColor:[UIColor lightGrayColor]];
    [alsoAddLabel setFont:[UIFont systemFontOfSize:15]];
    [mainView addSubview:alsoAddLabel];
    
    contactInCC = [[NSMutableArray alloc] initWithArray:message.header.cc];
    flagArray = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < contactInCC.count; counter++) {
        [flagArray setObject:@"0" atIndexedSubscript:counter];
    }
    
    contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 190, WIDTH, HEIGHT - 190 - 50)];
    [contactsTableView setBackgroundColor:CLEAR_COLOR];
    [contactsTableView setSeparatorInset:UIEdgeInsetsZero];
    [contactsTableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:CONTACT_CELL];
    [contactsTableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:contactCellIdentifier];
    contactsTableView.delegate = self;
    contactsTableView.dataSource = self;
    [contactsTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
    [mainView addSubview:contactsTableView];
    
    
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(60, HEIGHT - 50, WIDTH - 120, 40)];
    [doneButton setBackgroundColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
    [doneButton addTarget:self action:@selector(updateFunnel:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.clipsToBounds = YES;
    doneButton.layer.cornerRadius = 2.0;
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [mainView addSubview:doneButton];
    
    if(contactInCC.count == 0){
        alsoAddLabel.hidden = YES;
        doneButton.frame = CGRectMake(60, 190, WIDTH - 120, 40);
    }
    else{
        alsoAddLabel.hidden = NO;
        doneButton.frame = CGRectMake(60, HEIGHT  - 50, WIDTH - 120, 40);
    }
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(WIDTH-40, 70, 40, 40);
    //    [closeButton setBackgroundColor:[UIColor colorWithHexString:@"#1B8EEE"]];
    //    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    //    [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    //    [closeButton setTitleColor:WHITE_CLR forState:UIControlStateNormal];
    //    [closeButton setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateHighlighted];
    [closeButton setImage:[UIImage imageNamed:@"MPCloseBtn"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:closeButton];

    
    mainView.center = self.center;
    
    [self addSubview:mainView];
}

-(void)closeButtonClicked:(id)sender{
    [self setHidden:YES];
}

#pragma mark -
#pragma mark Event Handlers
- (void)updateFunnel:(UIButton*)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    [self performSelector:@selector(updateFunnelData) withObject:nil afterDelay:0.1];
    
}

-(void)updateFunnelData{
    
    [[Mixpanel sharedInstance] track:@"Updated Funnl"];
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
                [senderString appendFormat:@"%@,",tempCell.nameLabel.text];
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
    [[Mixpanel sharedInstance] track:@"Clicked away from funnlPopUp"];
    [self removeFromSuperview];
    [[(EmailsTableViewController*)viewController tableView] reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (contactInCC.count > 0) {
        return contactInCC.count;
    }
    return 0;
}

- (ContactTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCellIdentifier forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.nameLabel.text = [(MCOAddress*)[contactInCC objectAtIndex:indexPath.row] mailbox];
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
