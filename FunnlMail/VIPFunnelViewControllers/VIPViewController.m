//
//  VIPViewController.m
//  VIPFunnelCreationOptions
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import "VIPViewController.h"
#import "AppDelegate.h"
#import "ContactService.h"
#import "ContactModel.h"
#import "FXBlurView.h"

@interface VIPViewController ()

@end

@implementation VIPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedContact = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
//    [self.view setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.6]];
//    [self performSelectorOnMainThread:@selector(applyBackgroundImage) withObject:nil waitUntilDone:YES];

//    [self.view setBackgroundColor:[UIColor blackColor]];
//    [self retrieveContact];
//    [self setUpView];
}

- (void)viewWillAppear:(BOOL)animated {
    if (selectedContact) {
        [selectedContact removeAllObjects];
        if (contactMutableArray) {
            [contactMutableArray removeAllObjects];
        }
    }
    [self performSelectorOnMainThread:@selector(applyBackgroundImage) withObject:nil waitUntilDone:YES];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self retrieveContact];
    [self setUpView];
}

#pragma mark -
#pragma mark Helper
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
    backgroundView.tintColor = [UIColor lightGrayColor];
    backgroundView.blurRadius = 10;
    [self.view addSubview:backgroundView];
    backgroundView = nil;
    [backgroundView setUserInteractionEnabled:YES];
    backgroundView = nil;
}

- (void)retrieveContact {
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *VIPContactString = [[NSUserDefaults standardUserDefaults] objectForKey:@"contact_string"];
    if (VIPContactString) {
        NSData *data = [VIPContactString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *temp = [json objectForKey:@"results"];
        if (temp.count) {
            NSArray *contactArray = [[ContactService instance] retrieveAllContact];
            for (int counter = 0; counter < temp.count; counter++) {
                BOOL flagForDuplicates = FALSE;
                for (ContactModel *tempContact in contactArray) {
                    //checking for login user
                    if ([tempContact.email isEqualToString:[temp objectAtIndex:counter]] && ![[temp objectAtIndex:counter] isEqualToString:[[EmailService instance] userEmailID]]) {
                        if (!contactMutableArray) {
                            contactMutableArray = [[NSMutableArray alloc] init];
                        }
                        [contactMutableArray addObject:tempContact];
                        flagForDuplicates = TRUE;
                    }
                    else if ([[temp objectAtIndex:counter] isEqualToString:[[EmailService instance] userEmailID]]) {
                        flagForDuplicates = TRUE;
                        NSLog(@"Email of logged in user.");
                    }
                }
                if (!flagForDuplicates) {
                    ContactModel *tempModel = [[ContactModel alloc] init];
                    tempModel.email = [temp objectAtIndex:counter];
                    tempModel.name = [temp objectAtIndex:counter];
                    tempModel.thumbnail = [temp objectAtIndex:counter];
                    [contactMutableArray addObject:tempModel];
                    tempModel = nil;
                }
            }
        }
        else {
            [self retrieveVIPContactLocally];
        }
    }
    else {
        [self retrieveVIPContactLocally];
    }
}

- (void)retrieveVIPContactLocally {
    if (contactMutableArray) {
        [contactMutableArray removeAllObjects];
        contactMutableArray = nil;
    }
    contactMutableArray = [[NSMutableArray alloc] init];
    NSMutableArray *temp = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
    if (temp.count) {
        NSArray *contactArray = [[ContactService instance] retrieveAllContact];
        for (int counter = 0; contactMutableArray.count < 9 && counter < temp.count; counter++) {
            MCOIMAPMessage *message = [MCOIMAPMessage importSerializable:[(MessageModel*)temp[counter] messageJSON]];
            BOOL flagForDuplicates = FALSE;
            for (ContactModel *tempContact in contactArray) {
                //checking for login user
                if ([tempContact.email isEqualToString:message.header.sender.mailbox] && ![message.header.sender.mailbox isEqualToString:[[EmailService instance] userEmailID]]) {
                    if (!contactMutableArray) {
                        contactMutableArray = [[NSMutableArray alloc] init];
                    }
                    if (![self checkForDuplicate:tempContact]) {
                        [contactMutableArray addObject:tempContact];
                        flagForDuplicates = TRUE;
                    }
                }
                else if ([message.header.sender.mailbox isEqualToString:[[EmailService instance] userEmailID]]) {
                    flagForDuplicates = TRUE;
                    NSLog(@"Email of logged in user.");
                }
            }
            if (!flagForDuplicates) {
                ContactModel *tempModel = [[ContactModel alloc] init];
                tempModel.email = message.header.sender.mailbox;
                tempModel.name = message.header.sender.displayName;
                tempModel.thumbnail = @"";
                if (![self checkForDuplicate:tempModel]) {
                    [contactMutableArray addObject:tempModel];
                }
                tempModel = nil;
            }
        }
    }
    else {
        //old logic
        NSArray *contactArray = [[ContactService instance] retrieveAllContact];
        if (contactMutableArray) {
            [contactMutableArray removeAllObjects];
        }
        for (ContactModel *tempContact in contactArray) {
            if (tempContact.name && tempContact.email && ![tempContact.name isEqualToString:@""]) {
                if (!contactMutableArray) {
                    contactMutableArray = [[NSMutableArray alloc] init];
                }
                [contactMutableArray addObject:tempContact];
            }
        }
    }
    temp = nil;
}

- (BOOL)checkForDuplicate:(ContactModel *)contact {
    for (ContactModel *tempModel in contactMutableArray) {
        if ([tempModel.email isEqualToString:contact.email]) {
            return TRUE;
        }
    }
    return FALSE;
}

- (void)setUpView {
    UIView *backGroungView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [backGroungView setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
    [self.view addSubview:backGroungView];
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, WIDTH - 20, 95 - 30)];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    sampleLabel.text = @"We have analyzed your inbox and have found some key people. Tap a few to create a new Funnel!";
    sampleLabel.numberOfLines = 3;
    [sampleLabel setTextColor:[UIColor whiteColor]];
    sampleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [sampleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.view addSubview:sampleLabel];
    sampleLabel = nil;
    
    if (!buttonArray) {
        buttonArray = [[NSMutableArray alloc] init];
    }
    
    UIScrollView *sampleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, WIDTH, HEIGHT - 110 - 100)];
    [sampleScrollView setBackgroundColor:[UIColor clearColor]];
    
    float buttonSize = 75.0;
    int margin = 40;
//    int xMargine = 10;
    int x = 10;
//    int yMargine = 10;
    int y = 10;
    int label_height = 40;
    float color = 255;
    
    UIFont *labelFont = REGULAR_FONT_12;
    
    for (int counter = 0; counter < 9 && counter < contactMutableArray.count; counter++) {
        if (counter > 0)
            color = 255/(counter*2);
        unsigned long temp = counter % 8;
        NSArray *randomColors = GRADIENT_ARRAY;
        NSString *colorString = [randomColors objectAtIndex:temp];
        UIColor *color = [UIColor colorWithHexString:colorString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[(ContactModel*)[contactMutableArray objectAtIndex:counter] thumbnail]]];
        [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        fetcher.comment = [NSString stringWithFormat:@"%d",counter];
        GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
        [fetcher setAuthorizer:currentAuth];
        [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
        
        if (counter % 3 == 0) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
            
            if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length >= 1) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            else if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] email].length >= 1) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            tempButton.tag = counter;
            [tempButton addTarget:self action:@selector(contactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [sampleScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + buttonSize + 0, buttonSize, label_height)];
            if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length) {
                sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] name];
            }
            else {
                sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] email];
            }
            [sampleLabel setTextColor:[UIColor whiteColor]];
            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [sampleScrollView addSubview:sampleLabel];
            sampleLabel = nil;
        }
        else if (counter % 3 == 1) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y, buttonSize, buttonSize)];
            tempButton.tag = counter;
            if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length >= 1) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            else if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] email].length >= 1) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            [tempButton addTarget:self action:@selector(contactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [sampleScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y + buttonSize + 0, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length) {
                sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] name];
            }
            else {
                sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] email];
            }
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [sampleScrollView addSubview:sampleLabel];
            sampleLabel = nil;
        }
        else if (counter % 3 == 2) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y, buttonSize, buttonSize)];
            [tempButton addTarget:self action:@selector(contactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            tempButton.tag = counter;
            if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length >= 1) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            else if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] email].length >= 1) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            
            [tempButton setBackgroundColor:color];
            
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [sampleScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y + buttonSize + 0, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            if ([(ContactModel*)[contactMutableArray objectAtIndex:counter] name].length) {
                sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] name];
            }
            else {
                sampleLabel.text = [(ContactModel *)[contactMutableArray objectAtIndex:counter] email];
            }
            
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [sampleScrollView addSubview:sampleLabel];
            sampleLabel = nil;
            
            y = y + buttonSize + margin;
        }
    }
    [sampleScrollView setContentSize:CGSizeMake(WIDTH, y)];
    [self.view addSubview:sampleScrollView];
    sampleScrollView = nil;
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH - 165.0) / 2.0, HEIGHT - 100 + 15, 165, 25)];
    [sampleButton setTitle:@"Add to Funnel" forState:UIControlStateNormal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    sampleButton.clipsToBounds = YES;
    sampleButton.layer.cornerRadius = 5.0;
    sampleButton.layer.borderWidth = 1.0;
    sampleButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [sampleButton addTarget:self action:@selector(pushCreateFunnelViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sampleButton];
    sampleButton = nil;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT - 100 + 15 + 25 + 15, WIDTH, 15)];
    [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Remind Later" attributes:underlineAttribute];
    [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, @"Remind Later".length)];
    [sampleButton setAttributedTitle:tempString forState:UIControlStateNormal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(remindMeLaterPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sampleButton];
    sampleButton = nil;
    tempString = nil;
    underlineAttribute = nil;
}
#pragma mark -
#pragma mark Delegate
- (void)imageFetcher:(GTMHTTPFetcher *)imageFetcher finishedWithData:(NSData *)imageData error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
    }
    else {
        NSLog(@"--------> %@",imageFetcher.comment);
        UIButton *tempButton = [buttonArray objectAtIndex:[imageFetcher.comment integerValue]];
//        TextFieldCell *tempCell = (TextFieldCell*)[Tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[imageFetcher.comment integerValue] inSection:1]];
//        [tempCell.thumbnailImageView setImage:[UIImage imageWithData:imageData]];
        [tempButton setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        [tempButton setBackgroundColor:[UIColor clearColor]];
        [tempButton setTitle:@"" forState:UIControlStateNormal];
    }
}
#pragma mark -
#pragma mark Event Handler
- (void)contactButtonPressed:(UIButton*)sender {
    if ([selectedContact containsObject:[contactMutableArray objectAtIndex:sender.tag]]) {
        [selectedContact removeObjectIdenticalTo:[contactMutableArray objectAtIndex:sender.tag]];
        sender.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    else {
        [selectedContact addObject:[contactMutableArray objectAtIndex:sender.tag]];
        sender.layer.borderColor = [[UIColor colorWithHexString:BUTTON_BORDER_COLOR_SELECTED] CGColor];
    }
}

- (void)pushCreateFunnelViewController:(UIButton*)sender {
    if (selectedContact.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please select atleast one contact to create funnel." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    }
    else {
        VIPCreateFunnelViewController *viewControllerToBePushed = [[VIPCreateFunnelViewController alloc] initWithSelectedContactArray:selectedContact];
//        FMCreateFunnlViewController *viewControllerToBePushed = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:selectedContact];
//        [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
//        [viewControllerToBePushed.view setBackgroundColor:[UIColor whiteColor]];
        [self.navigationController pushViewController:viewControllerToBePushed animated:YES];
    }
}

- (void)remindMeLaterPressed:(UIButton*)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_VIP_ENABLED) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
